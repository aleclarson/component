
# TODO: Write a codemod that removes 'defineProps'?

require "isDev"

ReactComponent = require "ReactComponent"
emptyFunction = require "emptyFunction"
mergeDefaults = require "mergeDefaults"
assertTypes = require "assertTypes"
assertType = require "assertType"
getKind = require "getKind"
hasKeys = require "hasKeys"
isType = require "isType"
define = require "define"
sync = require "sync"
has = require "has"

module.exports = (type) ->
  type.defineValues typeImpl.values
  type.defineMethods typeImpl.methods
  type.initInstance typeImpl.initInstance

ReactCompositeComponent = require "ReactCompositeComponent"
ReactCompositeComponent.Mixin._processProps = (props) ->
  {processProps} = @_currentElement.type::
  if processProps then processProps props
  else props

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.values =

  _propPhases: -> []

typeImpl.methods =

  defineProps: (props) ->
    assertType props, Object

    if @_argTypes
      throw Error "'argTypes' is already defined!"

    propNames = []
    propTypes = {}
    propDefaults = {}
    requiredTypes = {}

    sync.each props, (prop, name) ->
      propNames.push name

      if not isType prop, Object
        propTypes[name] = prop
        return

      if has prop, "default"
        propDefaults[name] = prop.default

      if propType = prop.type

        if isType propType, Object
          propType = Shape propType

        if prop.required
          requiredTypes[name] = yes

        propTypes[name] = propType

    @_propTypes = propTypes

    @didBuild (type) ->

      if hasKeys propTypes
        type.propTypes = propTypes

      if hasKeys propDefaults
        type.propDefaults = propDefaults

    @_propPhases.push (props) ->
      for name in propNames
        prop = props[name]

        if prop is undefined

          if propDefaults[name] isnt undefined
            props[name] = prop = propDefaults[name]

          else if not requiredTypes[name]
            continue

        if isDev
          propType = propTypes[name]
          propType and assertType prop, propType, "props." + name

      return props
    return

  replaceProps: (func) ->
    assertType func, Function
    @_propPhases.unshift func
    return

  initProps: (func) ->
    assertType func, Function
    @_propPhases.push (props) ->
      func.call this, props
      return props
    return

typeImpl.initInstance = ->
  @willBuild instImpl.willBuild

#
# The 'instance' is a Component.Builder
#

instImpl = {}

# NOTE: Inherited 'propPhases' come after the phases of the subtype.
#       This allows for the subtype to edit the 'props' before the
#       supertype gets to inspect them.
instImpl.willBuild = ->

  phases = @_propPhases
  if phases.length
    processProps = (props) ->
      for phase in phases
        props = phase.call null, props
      return props

  if superImpl = @_kind and @_kind::_processProps
    processProps = superWrap processProps, superImpl

  if processProps
    @didBuild (type) ->
      define type::, "_processProps",
        value: processProps

  # Try to be the last 'didBuild' phase.
  @didBuild => @didBuild instImpl.didBuild

instImpl.didBuild = (type) ->
  return if ReactComponent isnt getKind type
  return if has type::, "_delegate"
  define type::, "_delegate",
    get: -> this

# Wraps a 'processProps' static method
# with the implementation of its supertype.
superWrap = (processProps, superImpl) ->
  return superImpl if not processProps
  return (props) ->
    superImpl.call this,
      processProps.call this, props
