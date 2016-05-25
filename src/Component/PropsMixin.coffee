
# TODO: Write a codemod that removes 'propTypes'.

ReactComponent = require "ReactComponent"
mergeDefaults = require "mergeDefaults"
assertType = require "assertType"
getKind = require "getKind"
define = require "define"
assert = require "assert"
guard = require "guard"
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
      assert not @_propTypes, "'propTypes' is already defined!"

      @_propTypes = propTypes

      @_didBuild.push (type) ->
        type.propTypes = propTypes

      unless @_propDefaults
        @createProps (props) ->
          return props or {}

      @initProps (props) ->

        return if isDev

        assertType props, Object

        guard ->
          validateTypes props, propTypes

        .fail (error) ->
          throwFailure error, { method: "_processProps", element: this, props, propTypes }

        return props

  propDefaults:
    get: -> @_propDefaults
    set: (propDefaults) ->

      assertType propDefaults, Object
      assert not @_propDefaults, "'propDefaults' is already defined!"

      @_propDefaults = propDefaults

      @_didBuild.push (type) ->
        type.propDefaults = propDefaults

      unless @_propTypes
        @createProps (props) ->
          return props or {}

      @initProps (props) ->

        assertType props, Object

        mergeDefaults props, propDefaults

        return props

  createProps: (fn) ->
    assertType fn, Function
    @_initProps.unshift fn
    return

  initProps: (fn) ->
    assertType fn, Function
    @_initProps.push fn
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

  # Try to be the last 'didBuild' phase.
  @_didBuild.push => @_didBuild.push instImpl.didBuild

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
      define type.prototype, "_processProps", processProps

instImpl.didBuild = (type) ->
  return if ReactComponent isnt getKind type
  return if has type.prototype, "_delegate"
  define type.prototype, "_delegate", get: -> this

# Wraps a 'processProps' static method
# with the implementation of its supertype.
superWrap = (processProps, superImpl) ->
  return superImpl if not processProps
  return (props) ->
    props = processProps props
    return superImpl props
