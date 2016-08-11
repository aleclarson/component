
# TODO: Write a codemod that removes 'propTypes'.

require "isDev"

ReactComponent = require "ReactComponent"
mergeDefaults = require "mergeDefaults"
assertTypes = require "assertTypes"
assertType = require "assertType"
Property = require "Property"
getKind = require "getKind"
define = require "define"
has = require "has"

module.exports = (type) ->
  type.defineValues typeImpl.values
  type.definePrototype typeImpl.prototype
  type.initInstance typeImpl.initInstance

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.values =

  _propTypes: null

  _propDefaults: null

  _initProps: -> []

typeImpl.prototype =

  propTypes:
    get: -> @_propTypes
    set: (propTypes) ->

      assertType propTypes, Object

      if @_propTypes
        throw Error "'propTypes' is already defined!"

      @_propTypes = propTypes

      @_didBuild.push (type) ->
        type.propTypes = propTypes

      if isDev
        @initProps (props) ->
          assertTypes props, propTypes

  propDefaults:
    get: -> @_propDefaults
    set: (propDefaults) ->

      assertType propDefaults, Object

      if @_propDefaults
        throw Error "'propDefaults' is already defined!"

      @_propDefaults = propDefaults

      @_didBuild.push (type) ->
        type.propDefaults = propDefaults

      @initProps (props) ->
        mergeDefaults props, propDefaults

  createProps: (func) ->
    assertType func, Function
    @_initProps.unshift func
    return

  initProps: (func) ->
    assertType func, Function
    @_initProps.push (props) ->
      func.call this, props
      return props
    return

typeImpl.initInstance = ->
  @_willBuild.push instImpl.willBuild

#
# The 'instance' is a Component.Builder
#

instImpl = {}

# NOTE: Inherited 'propPhases' come after the phases of the subtype.
#       This allows for the subtype to edit the 'props' before the
#       supertype gets to inspect them.
instImpl.willBuild = ->

  phases = @_initProps
  if phases.length
    processProps = (props) ->
      for phase in phases
        props = phase.call null, props
      return props

  if superImpl = @_kind and @_kind::_processProps
    processProps = superWrap processProps, superImpl

  if processProps
    @_didBuild.push (type) ->
      define type.prototype, "_processProps",
        value: processProps

  # Try to be the last 'didBuild' phase.
  @_didBuild.push => @_didBuild.push instImpl.didBuild

instImpl.didBuild = (type) ->
  return if ReactComponent isnt getKind type
  return if has type.prototype, "_delegate"
  define type.prototype, "_delegate", get: -> this

# Wraps a 'processProps' static method
# with the implementation of its supertype.
superWrap = (processProps, superImpl) ->
  return superImpl if not processProps
  return (props) -> superImpl processProps props
