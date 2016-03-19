
{ setKind, setType, isType, isKind,
  assertType, validateTypes, Void } = require "type-utils"

{ throwFailure } = require "failure"

{ sync } = require "io"

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
combine = require "combine"
define = require "define"
Random = require "random"
Event = require "event"
steal = require "steal"
hook = require "hook"
log = require "lotus-log"

NativeValue = require "./NativeValue"

Component = NamedFunction "Component", (name, config) ->

  assertType name, String, "name"
  assertType config, Object, "config"

  mixins = steal config, "mixins", []
  sync.each mixins, (mixin) ->
    assertType mixin, Function, { name, mixin, mixins }
    mixin config

  validateTypes config, Component.configTypes

  statics = steal config, "statics", {}

  styles = steal config, "styles"
  statics.styles = { value: StyleSheet.create styles } if styles?

  Component.enforcePropValidation name, config, statics
  Component.addPreventableRendering name, config
  Component.catchErrorsWhenRendering config
  Component.startReactionsWhenMounting config
  Component.stopReactionsWhenUnmounting config
  Component.stopListenersWhenUnmounting config
  Component.detachNativeValuesWhenUnmounting config

  type = Component.createType name,
    boundMethods: steal config, "boundMethods", []
    customValues: steal config, "customValues"
    init: steal config, "init", emptyFunction
    initState: steal config, "initState", emptyFunction
    initValues: steal config, "initValues", emptyFunction
    initReactiveValues: steal config, "initReactiveValues", emptyFunction
    initNativeValues: steal config, "initNativeValues", emptyFunction
    initListeners: steal config, "initListeners"

  statics = sync.map statics, (value, key) ->
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

  prototype = sync.map config, (value, key) -> {
    value
    enumerable: key[0] isnt "_"
    configurable: no
  }

  define type, statics
  define type.prototype, "styles", statics.styles
  define type.prototype, prototype

  statics.type = type
  factory = Component.createFactory type
  define factory, statics

module.exports = setKind Component, ReactComponent

define Component.prototype, ->
  @options = enumerable: no
  @
    __owners: get: ->
      owners = []
      instance = this
      while instance?
        owners.push instance
        instance = instance._reactInternalInstance._currentElement._owner?._instance
      owners

    __addReaction: (key, reaction, listener) ->
      unless @__reactions?
        define this, __reactions: { value: {}, enumerable: no }
      if @__reactions[key]?
        throw Error "Conflicting reactions are both named '#{key}'."
      @__reactions[key] = { reaction, listener }
      reaction

    __attachNativeValue: (key, nativeValue) ->
      assertType nativeValue, NativeValue.Kind
      @__nativeValues[key] = nativeValue
      define this, key,
        value: nativeValue
        enumerable: key[0] isnt "_"
        frozen: yes

    __createNativeValue: (key, value) ->
      return if value is undefined
      nativeValue = NativeValue value, @constructor.name + "." + key
      @__attachNativeValue key, nativeValue
      @__addReaction key, nativeValue._reaction if nativeValue.isReactive

define Component,

  configTypes: value:
    propTypes: [ Object, Void ]
    propDefaults: [ Object, Void ]
    events: [ Array, Void ]
    boundMethods: [ Array, Void ]
    customValues: [ Object, Void ]
    init: [ Function, Void ]
    initProps: [ Function, Void ]
    initState: [ Function, Void ]
    initValues: [ Function, Void ]
    initReactiveValues: [ Function, Void ]
    initNativeValues: [ Function, Void ]
    initListeners: [ Function, Void ]
    isRenderPrevented: [ Function.Kind, Void ]
    render: Function.Kind
    styles: [ Object, Void ]
    statics: [ Object, Void ]
    mixins: [ Array, Void ]

  # Constructs & initializes a ReactCompositeComponent.
  createType: (name, config) ->
    constructor = (props) ->
      inst = setType { props }, type
      try Component.initComponent.call inst, config, props
      catch error then throwFailure error, { method: "initComponent", componentName: name, component: inst, props }
      inst
    type = NamedFunction name, constructor
    setKind type, Component

  # Constructs a ReactElement.
  createFactory: (type) -> (props = {}) ->

    if isType props, Array
      props = combine.apply null, props

    if props.mixins?
      mixins = steal props, "mixins"
      assertType mixins, Array, "props.mixins"
      props = combine.apply null, [ {} ].concat mixins.concat props

    key = if props.key? then "" + props.key else null
    delete props.key

    ref = if props.ref? then props.ref else null
    delete props.ref

    define {}, ->
      @options = configurable: no
      @ {
        $$typeof: ReactElement.type
        type
        key
        ref
        props: value: props
        _owner: value: ReactCurrentOwner.current
        _store: value: { validated: no }
        _initError: Error()
      }

  initComponent: (config, props) ->
    prevAutoStart = Reaction.autoStart
    Reaction.autoStart = no
    Component.initBoundMethods.call this, config
    Component.initCustomValues.call this, config
    Component.initValues.call this, config
    Component.initReactiveValues.call this, config
    Component.initNativeValues.call this, config
    Component.initState.call this, config
    Component.initListeners.call this, config
    Reaction.autoStart = prevAutoStart
    config.init.call this

  initCustomValues: ({ customValues }) ->
    return unless isType customValues, Object
    define this, ->
      @options = configurable: no
      @ customValues

  initBoundMethods: (config) ->

    boundMethods = {}
    sync.each config.boundMethods, (key) =>
      method = this[key]
      unless isKind method, Function
        throw Error "'#{@constructor.name}.#{key}' must be a Function" +
          ", because you included it in the 'boundMethods' array."
      boundMethod = method.bind this
      boundMethod.toString = -> method.toString()
      boundMethods[key] =
        enumerable: key[0] isnt "_"
        value: boundMethod

    define this, ->
      @options = frozen: yes
      @ boundMethods

  initValues: (config) ->

    values = config.initValues.call this
    return unless values?

    values = sync.map values, (value, key) ->
      enumerable: key[0] isnt "_"
      value: value

    define this, ->
      @options = configurable: no
      @ values

  initReactiveValues: (config) ->

    values = config.initReactiveValues.call this
    return unless values?

    if isType values, Array
      values = combine.apply null, values

    unless isType values, Object
      error = TypeError "'initReactiveValues' must return an Object or Array!"
      throwFailure error, { values, component: this }

    reactions = {}
    values = sync.filter values, (reaction, key) =>
      return yes unless isType reaction, Reaction
      reactions[key] = reaction
      reaction.keyPath ?= @constructor.name + "." + key
      no

    values = sync.map values, (value, key) ->
      enumerable: key[0] isnt "_"
      reactive: yes
      value: value

    reactions = sync.map reactions, (reaction, key) =>
      @__addReaction key, reaction
      enumerable: key[0] isnt "_"
      get: -> reaction.value

    define this, ->
      @options = configurable: no
      @ values
      @ reactions

  initNativeValues: (config) ->
    nativeValues = config.initNativeValues.call this
    return unless nativeValues?
    assertType nativeValues, Object, "nativeValues"
    define this, __nativeValues: { value: {}, enumerable: no }
    sync.each nativeValues, (value, key) =>
      if isKind value, NativeValue
        @__attachNativeValue key, value
      else
        @__createNativeValue key, value

  initState: (config) ->
    state = config.initState.call this
    return unless state?
    assertType state, Object, "state"
    @state = state
    sync.each state, (value, key) =>
      return unless isType value, Reaction
      value.keyPath ?= @constructor.name + ".state." + key
      @state[key] = value._value
      @__addReaction "state.#{key}", value, (newValue) =>
        newProps = {}
        newProps[key] = newValue
        @setState newProps

  initListeners: (config) ->
    return unless config.initListeners?
    define this, __listeners: { value: [], enumerable: no }
    onListen = Event.didListen (event, listener) => @__listeners.push listener
    config.initListeners.call this
    onListen.stop()

  startReactionsWhenMounting: (config) ->
    hook.after config, "componentWillMount", ->
      return unless @__reactions?
      sync.each @__reactions, ({ reaction, listener }, key) =>
        reaction.addListener listener if listener?
        try reaction.start()
        catch error then throwFailure error, { key, reaction, component: this }

  stopReactionsWhenUnmounting: (config) ->
    hook.after config, "componentWillUnmount", ->
      return unless @__reactions?
      sync.each @__reactions, ({ reaction, listener }) ->
        reaction.stop()
        reaction.removeListener listener if listener?

  stopListenersWhenUnmounting: (config) ->
    return unless config.initListeners?
    hook.after config, "componentWillUnmount", ->
      sync.each @__listeners, (listener) ->
        listener.stop()

  detachNativeValuesWhenUnmounting: (config) ->
    hook.after config, "componentWillUnmount", ->
      return unless @__nativeValues?
      sync.each @__nativeValues, (value) ->
        value.detach()

  addPreventableRendering: (name, config) ->

    isRenderPrevented = steal config, "isRenderPrevented"
    return unless isRenderPrevented?

    hook.after config, "init", (args, values) ->

      shouldRender = Reaction.sync
        get: => not isRenderPrevented.call this
        didSet: (shouldRender) =>
          return unless @__needsRender and shouldRender
          @__needsRender = no
          try @forceUpdate()

      define this, ->
        @options = enumerable: no
        @ "__needsRender", value: no
        @ "__shouldRender", get: -> shouldRender.value

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

  catchErrorsWhenRendering: (config) ->

    # return unless __DEV__

    render = steal config, "render"

    renderSafely = ->
      try element = render.call this
      catch error
        element = @_reactInternalInstance._currentElement
        throwFailure error,
          method: "#{@constructor.name}.render"
          component: this
          stack: [ "::   When component was constructed  ::", element._initError ]
      element or no

    renderSafely.toString = -> render.toString()

    config.render = renderSafely

  enforcePropValidation: (name, config, statics) ->

    initProps = steal config, "initProps", emptyFunction
    propTypes = steal config, "propTypes"
    propDefaults = steal config, "propDefaults"

    events = steal config, "events"
    if events?.length > 0
      propTypes ?= {}
      propDefaults ?= {}
      sync.each events, (event) ->
        propTypes[event] = [ Function, Void ]
        propDefaults[event] = emptyFunction

    statics.propTypes = { value: propTypes, frozen: no }
    statics.propDefaults = { value: propDefaults }
    statics._processProps = (props) ->
      if propDefaults?
        if isType props, Object then Component.mergeDefaults props, propDefaults
        else props = combine {}, propDefaults
      initProps.call this, props
      # if __DEV__
      if propTypes? and isType props, Object
        try validateTypes props, propTypes
        catch error then throwFailure error, { method: "_processProps", element: this, props, propTypes }
      props

  mergeDefaults: (values, defaultValues) ->
    for key, defaultValue of defaultValues
      value = values[key]
      if isType defaultValue, Object
        if isType value, Object
          Component.mergeDefaults value, defaultValue
        else if value is undefined
          values[key] = combine {}, defaultValue
      else if value is undefined
        values[key] = defaultValue
    return
