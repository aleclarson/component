
# TODO: Write a codemod that removes 'defineProps'?

{mutable, frozen} = require "Property"

ReactComponent = require "ReactComponent"
assertType = require "assertType"
getKind = require "getKind"
hasKeys = require "hasKeys"
isType = require "isType"
sync = require "sync"
hook = require "hook"
has = require "has"

PropValidator = require "../utils/PropValidator"

module.exports = (type) ->
  type.defineMethods typeImpl.defineMethods
  type.initInstance typeImpl.initInstance

#
# The 'type' is the Component.Builder constructor
#

typeImpl =

  defineMethods:

    defineProps: (props) ->

      if @_propTypes
        throw Error "'defineProps' can only be called once!"

      props = PropValidator props

      # Expose `propTypes` and `propDefaults`.
      @_delegate.didBuild (type) ->
        type.propTypes = props.types
        type.propDefaults = props.defaults
        return

      # Validate props and set defaults.
      @_phases.props.push props.validate

      # Don't allow `defineProps` to be called again.
      frozen.define this, "_propTypes", {value: props.types}
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
      initProps = (props) ->
        for phase in propPhases
          props = phase.call null, props
        return props

    if superImpl = @_kind and @_kind.initProps
      initProps = superWrap initProps, superImpl

    initProps and @didBuild (type) ->
      frozen.define type, "initProps", {value: initProps}

    hook this, "_willReceiveProps", instImpl.willReceiveProps
    @didBuild instImpl.didBuild

  didBuild: (type) ->
    return if ReactComponent isnt getKind type
    return if has type::, "_delegate"
    mutable.define type::, "_delegate", {get: -> this}

# Wraps a 'initProps' static method
# with the implementation of its supertype.
superWrap = (initProps, superImpl) ->
  if initProps
  then (props) -> superImpl initProps props
  else superImpl
