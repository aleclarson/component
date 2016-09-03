
# TODO: Write a codemod that removes 'defineProps'?

require "isDev"

{mutable, frozen} = require "Property"

ReactComponent = require "ReactComponent"
assertType = require "assertType"
getKind = require "getKind"
hasKeys = require "hasKeys"
isType = require "isType"
sync = require "sync"
hook = require "hook"
has = require "has"

module.exports = (type) ->
  type.defineMethods typeImpl.defineMethods
  type.initInstance typeImpl.initInstance

ReactCompositeComponent = require "ReactCompositeComponent"
ReactCompositeComponent.Mixin._processProps = (props = {}) ->
  {processProps} = @_currentElement.type::
  if processProps then processProps props
  else props

#
# The 'type' is the Component.Builder constructor
#

typeImpl =

  defineMethods:

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

      frozen.define this, "_propTypes", {value: propTypes}

      @didBuild (type) ->

        if hasKeys propTypes
          type.propTypes = propTypes

        if hasKeys propDefaults
          type.propDefaults = propDefaults

      @_phases.props.push (props) ->
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
      @_phases.props.unshift func
      return

    initProps: (func) ->
      assertType func, Function
      @_phases.props.push (props) ->
        func.call this, props
        return props
      return

  initInstance: ->
    @_phases.props = []
    @initInstance instImpl.initInstance
    @willBuild instImpl.willBuild

#
# The 'instance' is a Component.Builder
#

instImpl =

  initInstance: ->
    delegate = @_delegate
    if delegate isnt this
      delegate._props = @props
    return

  willReceiveProps: (orig, props) ->
    orig.call this, props
    if delegate = props.delegate
      delegate._props = props
    return

  # NOTE: Inherited 'propPhases' come after the phases of the subtype.
  #       This allows for the subtype to edit the 'props' before the
  #       supertype gets to inspect them.
  willBuild: (type) ->

    propPhases = @_phases.props
    if propPhases.length
      processProps = (props) ->
        for phase in propPhases
          props = phase.call null, props
        return props

    if superImpl = @_kind and @_kind::_processProps
      processProps = superWrap processProps, superImpl

    processProps and @didBuild (type) ->
      frozen.define type::, "_processProps", {value: processProps}

    hook this, "_willReceiveProps", instImpl.willReceiveProps
    @didBuild instImpl.didBuild

  didBuild: (type) ->
    return if ReactComponent isnt getKind type
    return if has type::, "_delegate"
    mutable.define type::, "_delegate", {get: -> this}

# Wraps a 'processProps' static method
# with the implementation of its supertype.
superWrap = (processProps, superImpl) ->
  return superImpl if not processProps
  return (props) ->
    superImpl.call this,
      processProps.call this, props
