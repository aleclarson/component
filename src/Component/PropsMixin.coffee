
# TODO: Write a codemod that removes 'defineProps'?

{mutable, frozen} = require "Property"

ReactComponent = require "react/lib/ReactComponent"

emptyFunction = require "emptyFunction"
assertType = require "assertType"
getProto = require "getProto"
Builder = require "Builder"
inArray = require "in-array"
has = require "has"

PropValidator = require "../utils/PropValidator"
PropWatcher = require "../utils/PropWatcher"

module.exports = do ->

  mixin = Builder.Mixin()

  mixin.initInstance ->
    @willBuild ->
      ViewMixin.apply this
    return

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

    replaceProps: (callback) ->
      assertType callback, Function
      @_phases.unshift "props", callback
      return

    initProps: (callback) ->
      assertType callback, Function
      @_phases.push "props", (props) ->
        callback.call this, props
        return props
      return

    watchProp: (key, callback) ->

      watcher =
        if @_needs "propWatcher"
        then @_watchProps()
        else @_propWatcher

      watcher.add key, callback
      return

    _createProps: ->

      frozen.define this, "_props",
        value: props = PropValidator()

      statics =
        propTypes: props.types
        propDefaults: props.defaults
        requiredProps: props.requiredKeys

      for key, value of statics
        statics[key] = {value}

      @_delegate.defineStatics statics
      @defineStatics statics if @_delegate isnt this

      # Validate props and set defaults.
      @_phases.push "props", props.validate
      return props

    _watchProps: ->

      frozen.define this, "_propWatcher",
        value: watcher = PropWatcher()

      @defineListeners ->
        watcher.start @props, this

      @willReceiveProps (props) ->
        watcher.update props, this

      return watcher

  return mixin.apply

ViewMixin = do ->

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

  # NOTE: Inherited 'propPhases' come after the phases of the subtype.
  #       This allows for the subtype to edit the 'props' before the
  #       supertype gets to inspect them.
  mixin.willBuild do ->

    # Construct the `initProps` static method.
    PropInitializer = (kind, phases) ->

      if phases.length
        initProps = (props) ->
          for phase in phases
            props = phase.call null, props
          return props

      if superImpl = kind and kind.initProps
      then superWrap initProps, superImpl
      else initProps

    # Make the `_delegate` property point to `this` when no delegate is being used.
    setDefaultDelegate = (prototype) ->
      return if has prototype, "_delegate"
      if getProto(prototype).constructor is ReactComponent
        mutable.define prototype, "_delegate", {get: -> this}
        return

    attachProps = (props) ->
      if delegate = props.delegate
        delegate._props = props
        return

    return ->

      # Attach the first props as early as possible.
      @_values.unshift attachProps

      # Updated props must be attached to the delegate.
      willReceiveProps = @_willReceiveProps or emptyFunction
      @_willReceiveProps = (props) ->
        attachProps props
        willReceiveProps.call this, props
        return

      initProps = PropInitializer @_kind, @_phases.get "props"
      @didBuild (type) ->
        frozen.define type, "initProps", {value: initProps}
        setDefaultDelegate type.prototype
        return

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
    type = getProto(type.prototype).constructor
    types.push type
  return types
