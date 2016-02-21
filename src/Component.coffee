
{ setKind, setType, isType, isKind,
  assertType, validateTypes, Void } = require "type-utils"

{ sync } = require "io"

ReactCurrentOwner = require "ReactCurrentOwner"
ExceptionsManager = require "ExceptionsManager"
parseErrorStack = require "parseErrorStack"
ReactiveGetter = require "ReactiveGetter"
ReactComponent = require "ReactComponent"
NamedFunction = require "named-function"
reportFailure = require "report-failure"
emptyFunction = require "emptyFunction"
ReactElement = require "ReactElement"
flattenStyle = require "flattenStyle"
StyleSheet = require "StyleSheet"
Reaction = require "reaction"
combine = require "combine"
define = require "define"
Random = require "random"
steal = require "steal"
log = require "lotus-log"

NativeValue = require "./NativeValue"

Config =
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
  isRenderPrevented: [ Function.Kind, Void ]
  render: Function.Kind
  styles: [ Object, Void ]
  statics: [ Object, Void ]
  mixins: [ Array, Void ]

Component = NamedFunction "Component", (name, config) ->

  assertType name, String, "name"
  assertType config, Object, "config"

  mixins = steal config, "mixins", []
  sync.each mixins, (mixin) -> mixin config

  validateTypes config, Config

  statics = steal config, "statics", {}

  styles = steal config, "styles"
  statics.styles = StyleSheet.create styles if styles?

  _enforcePropValidation name, config, statics
  _addPreventableRendering name, config
  _catchErrorsWhenRendering config
  _startReactionsWhenMounting config
  _stopReactionsWhenUnmounting config

  type = _createType name,
    boundMethods: steal config, "boundMethods", []
    customValues: steal config, "customValues"
    init: steal config, "init", emptyFunction
    initState: steal config, "initState", emptyFunction
    initValues: steal config, "initValues", emptyFunction
    initReactiveValues: steal config, "initReactiveValues", emptyFunction
    initNativeValues: steal config, "initNativeValues", emptyFunction

  statics = sync.map statics, (value, key) ->
    value: value
    frozen: yes
    enumerable: key[0] isnt "_"

  prototype = sync.map config, (value, key) ->
    value: value
    frozen: yes
    enumerable: key[0] isnt "_"

  define type, statics
  define type.prototype, "styles", statics.styles
  define type.prototype, prototype

  statics.type = type
  factory = _createFactory type
  define factory, statics

setKind Component, ReactComponent

module.exports = Component

#
# Prototype
#

define Component.prototype, ->

  @options = frozen: yes
  @
    react: (options) ->
      options.sync ?= yes
      key = Random.id()
      reaction = Reaction options
      @_addReaction key, reaction

  @enumerable = no
  @
    _addReaction: (key, reaction, listener) ->
      @_reactions ?= {}
      if @_reactions[key]
        throw Error "Conflicting reactions are both named '#{key}'."
      @_reactions[key] = { reaction, listener }
      reaction

    _attachNativeValue: (key, nativeValue) ->
      assertType nativeValue, NativeValue.Kind
      @_nativeValues[key] = nativeValue
      define this, key,
        value: nativeValue
        enumerable: key[0] isnt "_"
        frozen: yes

    _createNativeValue: (key, value) ->
      return if value is undefined
      nativeValue = NativeValue value, @constructor.name + "." + key
      @_attachNativeValue key, nativeValue
      @_addReaction key, nativeValue._reaction if nativeValue.isReactive

#
# Internal
#

# Constructs & initializes a ReactCompositeComponent.
_createType = (name, config) ->
  type = NamedFunction name, _construct = (props) ->
    inst = setType { props }, type
    try _initComponent.call inst, config, props
    catch error
      reportFailure error, { method: "#{name}._initComponent", component: inst, props }
    inst
  setKind type, Component

# Constructs a ReactElement.
_createFactory = (type) -> (props = {}) ->

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

  stack = parseErrorStack Error()

  define {}, ->
    @options = configurable: no
    @ {
      $$typeof: ReactElement.type
      type
      key
      ref
      props: { value: props }
      _owner: { value: ReactCurrentOwner.current }
      _store: { value: validated: no }
      _stack: -> stack
    }

_initComponent = (config, props) ->

  define this, ->

    @options =
      enumerable: no
      configurable: no
    @
      _reactions: null
      _nativeValues: null

  prevAutoStart = Reaction.autoStart
  Reaction.autoStart = no
  _initBoundMethods.call this, config
  _initCustomValues.call this, config
  _initValues.call this, config
  _initReactiveValues.call this, config
  _initNativeValues.call this, config
  _initState.call this, config
  config.init.call this
  Reaction.autoStart = prevAutoStart

_initCustomValues = ({ customValues }) ->
  return unless isType customValues, Object
  define this, ->
    @options = configurable: no
    @ customValues

_initBoundMethods = (config) ->

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

_initValues = (config) ->

  values = config.initValues.call this
  return unless values?

  values = sync.filter values, (reaction, key) =>
    return yes unless isType reaction, Reaction
    error = Error "DEPRECATED: 'initValues' treats Reactions normally now!"
    try reportFailure error, { reaction, key, component: this }
    no

  values = sync.map values, (value, key) ->
    enumerable: key[0] isnt "_"
    value: value

  define this, ->
    @options = configurable: no
    @ values

_initReactiveValues = (config) ->

  values = config.initReactiveValues.call this
  return unless values?

  if isType values, Array
    values = combine.apply null, values

  unless isType values, Object
    error = TypeError "'initReactiveValues' must return an Object or Array!"
    reportFailure error, { values, component: this }

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
    @_addReaction key, reaction
    enumerable: key[0] isnt "_"
    get: -> reaction.value

  define this, ->
    @options = configurable: no
    @ values
    @ reactions

_initNativeValues = (config) ->
  nativeValues = config.initNativeValues.call this
  return unless nativeValues?
  assertType nativeValues, Object, "nativeValues"
  @_nativeValues = {}
  sync.each nativeValues, (value, key) =>
    if isKind value, NativeValue
      @_attachNativeValue key, value
    else
      @_createNativeValue key, value

_initState = (config) ->
  state = config.initState.call this
  return unless state?
  assertType state, Object, "state"
  @state = state
  sync.each state, (value, key) =>
    return unless isType value, Reaction
    value.keyPath ?= @constructor.name + ".state." + key
    @state[key] = value._value
    @_addReaction "state.#{key}", value, (newValue) =>
      newProps = {}
      newProps[key] = newValue
      @setState newProps

_startReactionsWhenMounting = (config) ->
  componentWillMount = steal config, "componentWillMount", emptyFunction
  config.componentWillMount = ->
    componentWillMount.call this
    return unless @_reactions?
    sync.each @_reactions, ({ reaction, listener }) =>
      reaction.addListener listener if listener?
      reaction.start()

_stopReactionsWhenUnmounting = (config) ->
  componentWillUnmount = steal config, "componentWillUnmount", emptyFunction
  config.componentWillUnmount = ->
    componentWillUnmount.call this
    return unless @_reactions?
    sync.each @_reactions, ({ reaction, listener }) ->
      reaction.stop()
      reaction.removeListener listener if listener?

_detachNativeValuesWhenUnmounting = ->
  componentWillUnmount = steal config, "componentWillUnmount", emptyFunction
  config.componentWillUnmount = ->
    componentWillUnmount.call this
    return unless @_nativeValues?
    sync.each @_nativeValues, (value) ->
      value.detach()

_addPreventableRendering = (name, config) ->

  return unless config.isRenderPrevented?

  initReactiveValues = steal config, "initReactiveValues", -> {}
  config.initReactiveValues = ->
    values = initReactiveValues.call this
    values.willRender = no
    values.preventRender = Reaction.sync
      get: => @isRenderPrevented()
      didSet: (preventRender) =>
        return if preventRender
        return unless @willRender
        @willRender = no
        try @forceUpdate()
    values

  shouldComponentUpdate = steal config, "shouldComponentUpdate", emptyFunction.thatReturnsTrue
  config.shouldComponentUpdate = (props, state) ->
    if @preventRender
      @willRender = yes
      return no
    shouldComponentUpdate.call this, props, state

  render = steal config, "render"
  config.render = ->
    if @preventRender
      @willRender = yes
      return no
    else
      render.call this

_catchErrorsWhenRendering = (config) ->

  # return unless __DEV__

  render = steal config, "render"

  renderSafely = ->
    try element = render.call this
    catch error
      stack = _getElementStack error, @_reactInternalInstance._currentElement
      try reportFailure error, { method: "#{@constructor.name}.render", component: this, stack }
      _reportException error, stack
    element or no

  renderSafely.toString = -> render.toString()

  config.render = renderSafely

_enforcePropValidation = (name, config, statics) ->

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

  statics.propTypes = propTypes
  statics.propDefaults = propDefaults
  statics._processProps = (props) ->
    if propDefaults?
      if isType props, Object then _mergeDefaults props, propDefaults
      else props = combine {}, propDefaults
    initProps.call this, props
    # if __DEV__
    if propTypes? and isType props, Object
      try validateTypes props, propTypes
      catch error
        stack = _getElementStack error, this
        try reportFailure error, { method: "#{name}._processProps", element: this, props, propTypes, stack }
        _reportException error, stack
    props

_mergeDefaults = (values, defaultValues) ->
  for key, defaultValue of defaultValues
    value = values[key]
    if isType defaultValue, Object
      if isType value, Object
        _mergeDefaults value, defaultValue
      else if value is undefined
        values[key] = combine {}, defaultValue
    else if value is undefined
      values[key] = defaultValue
  return

_getElementStack = (error, element) ->
  stack = parseErrorStack error
  if element._stack?
    stack.push "--- From when the component was constructed ---"
    stack = stack.concat element._stack()
  stack

_reportException = (error, stack) ->
  # return unless __DEV__
  return if GLOBAL._fatalException?
  ExceptionsManager.reportException error, yes, stack
