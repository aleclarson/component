
ReactCurrentOwner = require "../mocks/ReactCurrentOwner"
ReactElement = require "../mocks/ReactElement"
combine = require "combine"
Type = require "Type"

Component = require "."

type = Type "ComponentBuilder"

type.defineValues

  _hasReactions: no

  _hasNativeValues: no

  _hasListeners: no

  _viewType: ->
    type = Type()
    type.inherits ReactComponent
    return type

  _phases: ->
    willBuild: []
    didBuild: []

type.addMixins [
  require "./mixins/Props"
  require "./mixins/Styles"
  require "./mixins/GatedRender"
  require "./mixins/Lifecycle"
]

type.initInstance ->

  @initInstance ->
    @context.view = this

  @willBuild ->
    @willUnmount ->
      @context.view = null

# Add 'defineValues', 'defineFrozenValues', and 'defineReactiveValues'
# to the prototype of 'Component.Builder'
type.willBuild ->

  methods = {}

  keys = [ "defineValues", "defineFrozenValues", "defineReactiveValues" ]

  sync.each keys, (key) ->

    methods[key] = (values) ->

      values = sync.map values, (value) ->
        return value unless isType value, Function
        return -> value.apply @context, arguments

      @_viewType[key] values

  type.defineMethods methods

    defineValues: (values) ->

    defineFrozenValues: (values) ->

      values = sync.map values, (value, key) ->
        return value unless isType value, Function

type.defineMethods

  createListeners: (fn) ->

    assertType fn, Function

    unless @_hasListeners
      @_hasListeners = yes

      @_initInstance ->
        define this, "__listeners", []

      @willUnmount ->
        listener.stop() for listener in @__listeners
        return

    @_initInstance (args) ->

      onListen = Event.didListen (event, listener) =>
        @__listeners.push listener

      fn.apply this, args

      onListen.stop()

  defineNativeValues: (values) ->

    assertType values, Object

    unless @_hasNativeValues
      @_hasNativeValues = yes

      @_initInstance ->
        define this, "__nativeValues", Object.create null

      @willMount ->
        for key, nativeValue of @__nativeValues
          nativeValue.__attach()
        return

      @willUnmount ->
        for key, nativeValue of @__nativeValues
          nativeValue.__detach()
        return

    prop = Property { frozen: yes }

    # Functions are called for each instance!
    dynamicValues = Object.create null
    sync.each values, (value, key) ->
      return unless isType value, Function
      dynamicValues[key] = yes

    @_initInstance (args) ->
      for key, value of values
        value = value.apply this, args if dynamicValues[key]
        continue if value is undefined
        unless isType value, NativeValue.Kind
          nativeValue = NativeValue value, @constructor.name + "." + key
        else nativeValue = value
        @__nativeValues[key] = nativeValue
        prop.define this, key, nativeValue
      return

  defineReactions: (reactions) ->

    assertType reactions, Object

    unless @_hasReactions
      @_hasReactions = yes

      @_initInstance ->
        define this, "__reactions", Object.create null

      @willMount ->
        component = this
        for key, reaction of @__reactions
          guard -> reaction.start()
          .fail (error) -> throwFailure error, { key, reaction, component }
        return

      @willUnmount ->
        for key, reaction of @__reactions
          reaction.stop()
        return

    prop = Property { frozen: yes }

    @_initInstance (args) ->

      Reaction.inject.push "autoStart", yes

      for key, createReaction of reactions

        assertType createReaction, Function, key

        value = createReaction.apply this, args

        continue if value is undefined

        unless isType value, Reaction
          value = Reaction.sync value

        assert @__reactions[key] is undefined,
          reason: "Conflicting reactions are both named '#{key}'."

        @__reactions[key] = value

        prop.define this, key, value

      Reaction.inject.pop "autoStart"

  defineMethods: (methods) ->

    methods = sync.map methods, (method, key) ->
      return -> method.apply @context, arguments

    @_viewType.defineMethods methods

  defineProperties: (props) ->
    @_viewType.defineProperties props

  initInstance: (init) ->
    @_viewType.initInstance init

  willBuild: Builder::willBuild

  didBuild: Builder::didBuild

  build: ->

    if @_phases.willBuild.length
      for phase in @_phases.willBuild
        phase.call this

    type = @__createType @_viewType.build()

    if @_phases.didBuild.length
      for phase in @_phases.didBuild
        phase.call this

    return type

  _initInstance: (init) _>
    @_viewType._initInstance init

  __createType: (type) ->
    factory = @__createFactory type
    factory.type = type
    return factory

  __createFactory: (type) -> (props = {}) ->

    if props.mixins?
      mixins = steal props, "mixins"
      assertType mixins, Array, "props.mixins"
      props = combine.apply null, [ {} ].concat mixins.concat props

    key = null
    if props.key?
      key = steal props, "key"
      key = "" + key unless isType key, String

    element = {
      type
      key
      props
      $$typeof: ReactElement.type
    }

    define element,
      _owner: ReactCurrentOwner.current
      _store: value: { validated: no }
      _trace: Tracer "ReactElement()" if isDev

    return element

module.exports = type.build()
