
# TODO Batch synchronous changes in an appropriate timeframe (eg: 16ms).

{ isType, validateTypes, assertType, assert, Maybe, Kind } = require "type-utils"

{ AnimatedValue } = require "Animated"

{ roundToScreenScale } = require "device"

emptyFunction = require "emptyFunction"
Immutable = require "immutable"
Progress = require "progress"
Reaction = require "reaction"
Factory = require "factory"
combine = require "combine"
Tracer = require "tracer"
Event = require "event"
steal = require "steal"
isDev = require "isDev"
sync = require "sync"
hook = require "hook"

Animation = require "./Animation"

if isDev
  configTypes = {}
  configTypes.animate =
    type: Function.Kind
    onUpdate: Maybe Function.Kind
    onEnd: Maybe Function.Kind
    onFinish: Maybe Function.Kind

module.exports =
NativeValue = Factory "NativeValue",

  initArguments: (value, keyPath) ->
    assertType keyPath, String.Maybe, "keyPath"
    arguments

  getFromCache: (value) ->
    if isKind value, NativeValue then value else undefined

  customValues:

    keyPath:
      get: -> @_keyPath
      set: (keyPath) ->
        @_keyPath = keyPath
        @_reaction?.keyPath = keyPath

    value:
      get: -> @_value
      set: (newValue) ->

        assert not @isReactive,
          reason: "Cannot set 'value' when 'isReactive' is true!"
          nativeValue: this

        if @isAnimated
          @_animated.setValue newValue
          return

        @_setValue newValue

    getValue: lazy: ->
      => @_value

    fromValue: get: ->
      @_fromValue

    toValue: get: ->
      @_toValue

    distance: get: ->
      @_toValue - @_fromValue

    progress:
      get: -> @getProgress()
      set: (progress) ->
        @setProgress { progress, clamp: yes, round: yes }

    animation: get: ->
      @_animation

    isAnimated: get: ->
      @_animated isnt null

    isAnimating: get: ->
      @_animation isnt null

    isReactive: get: ->
      @_reaction?

    reaction:
      get: -> @_reaction
      set: (newValue, oldValue) ->
        return if newValue is oldValue
        @_attachReaction newValue

  initFrozenValues: ->

    didSet: Event()

    didAnimationEnd: Event { maxRecursion: 10 }

  initValues: (value, keyPath) ->

    _keyPath: keyPath

    _inputRange: null

    _easing: null

    _reaction: null

    _reactionListener: null

    _animated: null

    _animation: null

    _animatedListener: null

    _tracer: emptyFunction

  initReactiveValues: ->

    _value: null

    _fromValue: null

    _toValue: null

  init: (value, keyPath) ->

    if isType value, Reaction
      value.keyPath ?= keyPath
      @reaction = value

    else if isType value, Function.Kind
      @reaction = Reaction.sync { keyPath, get: value }

    else if isType value, Object
      value.keyPath ?= keyPath
      @reaction = Reaction.sync value

    else
      @value = value

  detach: ->
    # TODO This cleanup should involve a reference count.
    # @_detachReaction()
    # @_detachAnimated()

  absorb: (nativeValues...) ->
    newValue = @value
    sync.each nativeValues, (nativeValue) ->
      newValue += nativeValue.value
      nativeValue.value = 0
    @value = newValue

  animate: (config) ->

    assert not @isReactive,
      reason: "Cannot call 'animate' when 'isReactive' is true!"
      nativeValue: this

    @_tracer = Tracer "When the Animation was created" if isDev

    @_animation.stop() if @_animation

    @_attachAnimated()

    validateTypes config, configTypes.animate if isDev

    onUpdate = steal config, "onUpdate", emptyFunction
    onFinish = steal config, "onFinish", emptyFunction
    onEnd = steal config, "onEnd", emptyFunction

    hasEnded = no

    animation = Animation
      animated: @_animated
      type: steal config, "type"
      config: config

      onUpdate: (value) =>

        assert not hasEnded, "Must be animating!"

        assert @isAnimating, "Must be animating!"
        # assert animation.isActive, "Animation must be active!"
        onUpdate value

      onEnd: (finished) =>

        assert not hasEnded, "Must be animating!"
        hasEnded = yes

        # Must set this before callbacks (in case they start another animation)!
        @_animation = null

        onFinish() if finished
        onEnd finished

        @didAnimationEnd.emit finished

    @_fromValue = animation.fromValue
    @_toValue = animation.toValue
    @_animation = animation

  getProgress: (options) ->

    assert not @isReactive,
      reason: "Cannot call 'getProgress' when 'isReactive' is true!"
      nativeValue: this

    optionDefaults =
      at: @_value
      to: @_toValue
      from: if @_fromValue? then @_fromValue else @_value

    options = combine optionDefaults, options

    validateTypes options,
      at: Number
      to: Number
      from: Number
      clamp: Boolean.Maybe

    value = steal options, "at"
    Progress.fromValue value, options

  setProgress: (options) ->

    assert not @isReactive,
      reason: "Cannot call 'setProgress' when 'isReactive' is true!"
      nativeValue: this

    if isType options, Number
      options = { progress: options }

    optionDefaults =
      from: @_fromValue
      to: @_toValue

    options = combine optionDefaults, options

    validateTypes options,
      progress: Number
      from: Number
      to: Number
      clamp: Boolean.Maybe
      round: Boolean.Maybe

    progress = steal options, "progress"

    progress = @_applyInputRange progress if @_inputRange?

    progress = @_easing progress if @_easing?

    value = Progress.toValue progress, options

    value = roundToScreenScale value if options.round is yes

    @value = value

  willProgress: (config) ->

    assert not @isReactive,
      reason: "Cannot call 'willProgress' when 'isReactive' is true!"
      nativeValue: this

    validateTypes config,
      from: Number.Maybe
      to: Number
      within: Array.Maybe
      easing: Function.Maybe

    { to, from, within, easing } = config

    if within?
      assert within.length is 2
      assert within[0] <= within[1]

    @_inputRange = within
    @_easing = easing

    @_fromValue = from ?= @_value
    @_toValue = to

  _setValue: (newValue) ->
    assertType newValue, @type, { nativeValue: this, stack: @_tracer() } if @type isnt undefined
    return if @_value is newValue
    @_value = newValue
    @didSet.emit newValue

  _applyInputRange: (value) ->
    assert @_inputRange, Array
    [ min, max ] = @_inputRange
    value = Math.max min, Math.min max, value
    (value - min) / (max - min)

  _attachReaction: (reaction) ->
    return @_detachReaction() unless reaction
    if isType reaction, [ Object, Function.Kind ]
      reaction = Reaction.sync reaction
    assertType reaction, Reaction
    if @isReactive then @_detachReaction()
    else @_detachAnimated()
    @_tracer = reaction._traceInit
    @_reaction = reaction
    @_reaction.keyPath ?= @keyPath
    @_reactionListener = @_reaction.didSet (newValue) =>
      @_setValue newValue
    @_setValue reaction.value

  _attachAnimated: ->
    return if @_animated
    @_animated = new AnimatedValue @_value
    @_animatedListener = @_animated.didSet (value) => @_setValue value

  _detachReaction: ->
    return unless @isReactive
    @_reactionListener.stop()
    @_reactionListener = null
    @_reaction = null
    return

  _detachAnimated: ->
    return unless @isAnimated
    @_animated.stopAnimation()
    @_animatedListener.stop()
    @_animatedListener = null
    @_animated = null
    return
