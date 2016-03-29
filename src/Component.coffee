
{ Maybe
  setKind
  setType
  isType
  assertType
  validateTypes } = require "type-utils"

{ throwFailure } = require "failure"

sync = require "sync"

ReactCurrentOwner = require "ReactCurrentOwner"
ExceptionsManager = require "ExceptionsManager"
ReactiveGetter = require "ReactiveGetter"
ReactComponent = require "ReactComponent"
NamedFunction = require "named-function"
emptyFunction = require "emptyFunction"
ReactElement = require "ReactElement"
flattenStyle = require "flattenStyle"
StyleSheet = require "StyleSheet"
Reaction = require "reaction"
Injector = require "injector"
combine = require "combine"
define = require "define"
Random = require "random"
Event = require "event"
guard = require "guard"
isDev = require "isDev"
steal = require "steal"
hook = require "hook"

ReactionInjector = Injector "Reaction"

NativeValue = require "./NativeValue"

Component = NamedFunction "Component", (name, config) ->

  assertType name, String, "name"
  assertType config, Object, "config"

  Component.applyMixins config, name

  validateTypes config, Component.configTypes

  type = Component.createType config, name

  factory = Component.createFactory type

  styles = Component.createStyles config

  define factory, Component.createStatics config, type, styles

  define type.prototype, Component.createPrototype config, styles

  return factory

module.exports = setKind Component, ReactComponent

define Component,

  configTypes: value:
    propTypes: Object.Maybe
    propDefaults: Object.Maybe
    events: Array.Maybe
    boundMethods: Array.Maybe
    customValues: Object.Maybe
    init: Function.Maybe
    initProps: Function.Maybe
    initState: Function.Maybe
    initValues: Function.Maybe
    initReactiveValues: Function.Maybe
    initNativeValues: Function.Maybe
    initListeners: Function.Maybe
    isRenderPrevented: Maybe Function.Kind
    render: Function.Kind
    styles: Object.Maybe
    statics: Object.Maybe
    mixins: Array.Maybe

  applyMixins: (config, name) ->

    mixins = steal config, "mixins", []
    sync.each mixins, (mixin, key) ->
      assertType mixin, Function, { name, key, mixin, mixins }
      mixin config, name

    sync.each Component.mixins, (mixin, key) ->
      assertType mixin, Function, { name, key, mixin, mixins }
      mixin config, name

  createStyles: (config) ->
    return unless config.styles
    StyleSheet.create steal config, "styles"

  createStatics: (config, type, styles) ->
    statics = steal config, "statics", {}
    statics.type = type
    statics.styles = { value: styles } if styles
    return sync.map statics, (value, key) ->
      enumerable = key[0] isnt "_"
      if isType value, Object
        value.frozen ?= yes
        value.enumerable ?= enumerable
        return value
      return {
        value
        frozen: yes
        enumerable
      }

  createPrototype: (config, styles) ->
    config.styles = styles if styles
    return sync.map config, (value, key) ->
      configurable: no
      enumerable: key[0] isnt "_"
      value: value

  # Returns a Function that creates a ReactCompositeComponent.
  createType: (config, name) ->

    initPhases = {}
    sync.each Component.initPhases, (createPhase, key) ->
      initPhase = createPhase config, name
      initPhases[key] = initPhase if initPhase

    constructor = (props) ->
      component = setType { props }, type
      guard -> Component.initialize component, initPhases
      .fail (error) -> throwFailure error, { component, props, stack: (steal props, "__stack")() }
      component

    type = NamedFunction name, constructor
    setKind type, Component

  # Returns a Function that creates a ReactElement.
  createFactory: (type) -> (props = {}) ->

    if isType props, Array
      props = combine.apply null, props

    if props.mixins
      mixins = steal props, "mixins"
      assertType mixins, Array, "props.mixins"
      props = combine.apply null, [ {} ].concat mixins.concat props

    key = if props.key then "" + props.key else null
    delete props.key

    ref = if props.ref then props.ref else null
    delete props.ref

    if isDev
      stack = [ "::  When component was constructed  ::", Error() ]
      props.__stack = -> stack

    return {
      type
      key
      ref
      props
      $$typeof: ReactElement.type
      _owner: ReactCurrentOwner.current
      _store: { validated: no }
    }

  initialize: (component, initPhases) ->
    sync.each initPhases, (init, key) ->
      guard -> init.call component
      .fail (error) -> throwFailure error, { component, key, init }

  mixins: value:

    enforcePropValidation: (config, name) ->

      initProps = steal config, "initProps", emptyFunction
      propTypes = steal config, "propTypes"
      propDefaults = steal config, "propDefaults"

      events = steal config, "events"
      if events?.length > 0
        propTypes ?= {}
        propDefaults ?= {}
        sync.each events, (event) ->
          propTypes[event] = Function.Maybe
          propDefaults[event] = emptyFunction

      statics = config.statics ?= {}
      statics.propTypes = { value: propTypes, frozen: no }
      statics.propDefaults = { value: propDefaults }
      statics._processProps = (props) ->
        if propDefaults
          if isType props, Object then mergeDefaults props, propDefaults
          else props = combine {}, propDefaults
        initProps.call this, props
        if isDev and propTypes and isType props, Object
          guard -> validateTypes props, propTypes
          .fail (error) -> throwFailure error, { method: "_processProps", element: this, props, propTypes }
        props

    addPreventableRendering: (config, name) ->

      isRenderPrevented = steal config, "isRenderPrevented"
      return unless isRenderPrevented

      hook.after config, "init", (args, values) ->

        shouldRender = Reaction.sync
          get: => not isRenderPrevented.call this
          didSet: (shouldRender) =>
            return unless @__needsRender and shouldRender
            @__needsRender = no
            try @forceUpdate()

        define this, { enumerable: no },
          __needsRender: { value: no }
          __shouldRender: { get: -> shouldRender.value }

      shouldUpdate = steal config, "shouldComponentUpdate", emptyFunction.thatReturnsTrue
      config.shouldComponentUpdate = ->
        return shouldUpdate.apply this, arguments if @__shouldRender
        @__needsRender = yes
        return no

      render = steal config, "render"
      config.render = ->
        return render.call this if @__shouldRender
        @__needsRender = yes
        return no

    catchErrorsWhenRendering: (config, name) ->

      # return unless isDev

      render = steal config, "render"

      renderSafely = ->
        guard => render.call this
        .fail (error) =>
          element = @_reactInternalInstance._currentElement
          throwFailure error,
            method: "#{@constructor.name}.render"
            component: this
            stack: element.props.__stack()
          return no

      renderSafely.toString = -> render.toString()

      config.render = renderSafely

    startReactionsWhenMounting: (config) ->
      hook.after config, "componentWillMount", ->
        return unless @__reactions
        component = this
        sync.each @__reactions, ({ reaction, listener }, key) ->
          guard -> reaction.start()
          .fail (error) -> throwFailure error, { key, reaction, component }

    stopReactionsWhenUnmounting: (config) ->
      hook.after config, "componentWillUnmount", ->
        return unless @__reactions
        sync.each @__reactions, ({ reaction, listener }) ->
          listener.stop() if listener
          reaction.release()

    stopListenersWhenUnmounting: (config) ->
      return unless config.initListeners
      hook.after config, "componentWillUnmount", ->
        sync.each @__listeners, (listener) ->
          listener.stop()

    detachNativeValuesWhenUnmounting: (config) ->
      hook.after config, "componentWillUnmount", ->
        return unless @__nativeValues
        sync.each @__nativeValues, (value) ->
          value.detach()

  initPhases: value:

    boundMethods: (config) ->
      return unless config.boundMethods
      boundMethods = steal config, "boundMethods"
      return ->
        values = {}
        sync.each boundMethods, (key) =>
          method = this[key]
          return unless method and method.apply
          values[key] =
            enumerable: key[0] isnt "_"
            value: => method.apply this, arguments
        define this, values

    customValues: (config) ->
      return unless config.customValues
      customValues = steal config, "customValues"
      return -> define this, customValues

    initValues: (config) ->
      return unless config.initValues
      initValues = steal config, "initValues"
      return ->
        values = initValues.call this
        return unless values
        assertType values, Object
        define this, sync.map values, (value, key) ->
          { value, enumerable: key[0] isnt "_" }

    initReactiveValues: (config) ->
      return unless config.initReactiveValues
      initReactiveValues = steal config, "initReactiveValues"
      return ->
        values = initReactiveValues.call this
        return unless values
        assertType values, Object
        define this, sync.map values, (value, key) ->
          enumerable: key[0] isnt "_"
          reactive: yes
          value: value

    initNativeValues: (config) ->
      return unless config.initNativeValues
      initNativeValues = steal config, "initNativeValues"
      return ->
        ReactionInjector.push "autoStart", no
        values = initNativeValues.call this
        ReactionInjector.pop "autoStart"
        return unless values
        assertType values, Object
        define this, "__nativeValues", { value: {}, enumerable: no }
        sync.each values, (value, key) =>
          if isType value, NativeValue.Kind
            @__attachNativeValue key, value
          else @__createNativeValue key, value

    initState: (config) ->
      return unless config.initState
      initState = steal config, "initState"
      return ->
        state = initState.call this
        return unless state
        assertType state, Object
        @state = state

    initReactions: (config) ->
      return unless config.initReactions
      initReactions = steal config, "initReactions"
      optionCreators = initReactions()
      assertType optionCreators, Object
      return ->
        values = {}
        ReactionInjector.push "autoStart", no
        sync.each optionCreators, (createOptions, key) =>
          options = createOptions.call this
          return unless options
          if isType options, Function.Kind
            options = { get: options }
          if isType options, Object
            options.sync ?= yes
            value = Reaction options
          else value = options
          if isType value, Reaction
            @__addReaction key, value
          values[key] = { value, enumerable: key[0] isnt "_" }
        ReactionInjector.pop "autoStart"
        define this, values

    initListeners: (config) ->
      return unless config.initListeners
      initListeners = steal config, "initListeners"
      return ->
        define this, "__listeners", { value: [], enumerable: no }
        onListen = Event.didListen (event, listener) => @__listeners.push listener
        initListeners.call this
        onListen.stop()

    init: (config) ->
      steal config, "init"

define Component.prototype, { enumerable: no },

  __owners: get: ->
    owners = []
    instance = this
    while instance?
      owners.push instance
      instance = instance._reactInternalInstance._currentElement._owner?._instance
    owners

  __addReaction: (key, reaction, listener) ->
    define this, "__reactions", { value: {}, enumerable: no } unless @__reactions
    assert @__reactions[key] is undefined, "Conflicting reactions are both named '#{key}'."
    listener = reaction.didSet listener if listener
    @__reactions[key] = { reaction, listener }
    return

  __attachNativeValue: (key, nativeValue) ->
    assertType nativeValue, NativeValue.Kind
    @__nativeValues[key] = nativeValue
    define this, key,
      value: nativeValue
      enumerable: key[0] isnt "_"
      frozen: yes
    return

  __createNativeValue: (key, value) ->
    return if value is undefined
    nativeValue = NativeValue value, @constructor.name + "." + key
    @__attachNativeValue key, nativeValue
    @__addReaction key, nativeValue._reaction if nativeValue.isReactive
    return

#
# Helpers
#

mergeDefaults = (values, defaultValues) ->
  for key, defaultValue of defaultValues
    value = values[key]
    if isType defaultValue, Object
      if isType value, Object
        mergeDefaults value, defaultValue
      else if value is undefined
        values[key] = combine {}, defaultValue
    else if value is undefined
      values[key] = defaultValue
  return
