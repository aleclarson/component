
# TODO: Write a codemod that removes 'defineProps'?

{mutable, frozen} = require "Property"

ReactComponent = require "ReactComponent"
assertType = require "assertType"
getProto = require "getProto"
Builder = require "Builder"
getKind = require "getKind"
inArray = require "in-array"
hook = require "hook"
has = require "has"

PropValidator = require "../utils/PropValidator"

module.exports = do ->

  mixin = Builder.Mixin()

  mixin.initInstance ->
    @_phases.props = []
    BuilderMixin.apply this

  mixin.defineMethods

    inheritProps: (type, options) ->
      {propTypes, requiredProps} = type.componentType or type
      propConfigs = {}
      exclude = options?.exclude
      for key, propType of propTypes
        unless inArray exclude, key
          propConfigs[key] =
            if requiredProps[key]
            then {type: propType, required: yes}
            else propType
      @defineProps propConfigs
      return

    definePropDefaults: (values) ->
      props = @_props or @_createProps()
      props.setDefaults values
      return

    defineProps: (propConfigs) ->
      props = @_props or @_createProps()
      props.define propConfigs
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

    _createProps: ->

      frozen.define this, "_props",
        value: props = PropValidator()

      # Expose 'propTypes' and 'propDefaults' on the instance constructor
      @_delegate.defineStatics statics =
        propTypes: props.types
        propDefaults: props.defaults
        requiredProps: props.requiredKeys

      # Expose them on the element constructor, too
      if @_delegate isnt this
        @defineStatics statics

      # Validate props and set defaults.
      @_phases.props.push props.validate
      return props

  return mixin.apply

BuilderMixin = do ->

  mixin = Builder.Mixin()

  mixin.defineStatics

    parseProps: (input) ->
      assertType input, Object
      props = {}
      componentTypes = gatherTypes @componentType or this
      for componentType in componentTypes
        if propTypes = componentType.propTypes
          for key, propType of propTypes
            continue if input[key] is undefined
            continue if props[key] isnt undefined
            props[key] = input[key]
      return props

  mixin.initInstance ->
    delegate = @_delegate
    if delegate isnt this
      delegate._props = @props
    return

  # NOTE: Inherited 'propPhases' come after the phases of the subtype.
  #       This allows for the subtype to edit the 'props' before the
  #       supertype gets to inspect them.
  mixin.willBuild ->

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

    hook this, "_willReceiveProps", willReceiveProps
    @didBuild didBuild

  willReceiveProps = (orig, props) ->
    orig.call this, props
    if delegate = props.delegate
      delegate._props = props
    return

  didBuild = (type) ->
    return if ReactComponent isnt getKind type
    return if has type::, "_delegate"
    mutable.define type::, "_delegate", {get: -> this}

  return mixin

#
# Helpers
#

# Wraps a 'initProps' static method
# with the implementation of its supertype.
superWrap = (initProps, superImpl) ->
  if initProps
  then (props) -> superImpl initProps props
  else superImpl

gatherTypes = (type) ->
  types = [type]
  while type isnt Object
    type = getParentType type
    types.push type
  return types

getParentType = (type) ->
  getProto(type.prototype).constructor
