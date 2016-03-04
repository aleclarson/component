
# TODO Batch synchronous changes in an appropriate timeframe (eg: 16ms).

{ isType, validateTypes, assertType, assert, Void } = require "type-utils"

{ sync, async } = require "io"

emptyFunction = require "emptyFunction"
Listenable = require "listenable"
Immutable = require "immutable"
Animated = require "Animated"
Progress = require "progress"
Reaction = require "reaction"
Factory = require "factory"
combine = require "combine"
steal = require "steal"
hook = require "hook"

module.exports =
NativeValue = Factory "NativeValue",

  initArguments: (value, keyPath) ->
    assertType keyPath, [ String, Void ], "keyPath"
    arguments

  create: (value) ->
    if isKind value, NativeValue then value else {}

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
        else
          @_setValue newValue

    getValue: lazy: ->
      => @_value

    toValue: get: ->
      @_animated?._animation?._toValue or @_value

    progress:
      get: -> @getProgress()
      set: (progress) ->
        @setProgress progress

    isAnimated: get: ->
      @_animated?

    isAnimating: get: ->
      @_animating

    velocity: get: ->
      @_animated?._animation?._lastVelocity

    isReactive: get: ->
      @_reaction?

    reaction:
      get: -> @_reaction
      set: (newValue, oldValue) ->
        return @_removeReaction() unless newValue?
        newValue = Reaction.sync newValue if isType newValue, Function.Kind
        assertType newValue, Reaction
        if @isReactive then @_removeReaction()
        else @_removeAnimated()
        @_reaction = newValue
        @_reaction.keyPath ?= @keyPath
        @_reactionListener = @_setValue.bind this
        @_reactionListener newValue.value
        @_reaction.addListener @_reactionListener

  initValues: (value, keyPath) ->
    type: null
    _keyPath: keyPath
    _inputRange: null
    _easing: null
    _reaction: null
    _reactionListener: null
    _animated: null
    _animatedListener: null

  initReactiveValues: ->
    _animating: no
    _fromValue: null
    _toValue: null
    _value: null

  init: (value, keyPath) ->

    Listenable this, { eventNames: yes }

    if isType value, Reaction
      value.keyPath ?= keyPath
      @reaction = value

    else if isType value, Function.Kind
      @reaction = Reaction.sync { keyPath, get: value, autoStart: no }

    else if isType value, Object
      value.keyPath ?= keyPath
      value.autoStart ?= no
      @reaction = Reaction.sync value

    else
      @value = value

  detach: ->
    # TODO This cleanup should involve a reference count.
    # @_removeReaction()
    # @_removeAnimated()

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

    validateTypes config,
      onUpdate: [ Function.Kind, Void ]
      onEnd: [ Function.Kind, Void ]
      onFinish: [ Function.Kind, Void ]

    @stopAnimation()

    @_initAnimatedValue()

    onUpdate = steal config, "onUpdate"
    if onUpdate?
      listener = @_animated.addListener (result) =>
        onUpdate result.value

    onEnd = steal config, "onEnd", emptyFunction
    onFinish = steal config, "onFinish", emptyFunction

    @_fromValue = @_value
    @_toValue = config.toValue

    # Create the Animation and start it.
    (Animated[@_getAnimatedMethod config] @_animated, config).start()

    # If the Animation finishes instantly, this value is undefined.
    animation = @_animated._animation

    unless animation?
      @_animated.removeListener listener if onUpdate?
      finished = (not @_toValue?) or (@_value is @_toValue)
      onFinish() if finished
      onEnd finished
      return

    @_animating = yes

    hook.after animation, "__onEnd", ({ finished }) =>
      @_animating = no
      @_animated.removeListener listener if onUpdate?
      finished = @_value is @_toValue if @_toValue?
      onFinish() if finished
      onEnd finished

    return

  finishAnimation: ->
    return unless @isAnimated
    @_animated._value = @_toValue
    @_value = @_animated.__getValue()
    @_animated.stopAnimation()

  stopAnimation: ->
    return unless @isAnimated
    @_animated.stopAnimation()
    return

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
      clamp: [ Boolean, Void ]

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
      clamp: [ Boolean, Void ]

    progress = steal options, "progress"

    progress = @_applyInputRange progress if @_inputRange?

    progress = @_easing progress if @_easing?

    @value = Progress.toValue progress, options

  willProgress: (config) ->

    assert not @isReactive,
      reason: "Cannot call 'willProgress' when 'isReactive' is true!"
      nativeValue: this

    validateTypes config,
      from: [ Number, Void ]
      to: Number
      within: [ Array, Void ]
      easing: [ Function, Void ]

    { to, from, within, easing } = config

    if within?
      assert within.length is 2
      assert within[0] <= within[1]

    @_inputRange = within
    @_easing = easing

    @_fromValue = from ?= @_value
    @_toValue = to

  _setValue: (newValue) ->
    assertType newValue, @type if @type?
    @_value = newValue
    @_emit "didSet", newValue

  _applyInputRange: (value) ->
    assert @_inputRange, Array
    [ min, max ] = @_inputRange
    value = Math.max min, Math.min max, value
    (value - min) / (max - min)

  _initAnimatedValue: ->
    return if @_animated?
    @_animated = new Animated.Value @_value
    listener = ({ value }) => @_setValue value
    @_animatedListener = @_animated.addListener listener

  _getAnimatedMethod: (config) ->
    if config.duration? then return "timing"
    else if config.deceleration? then return "decay"
    else if (config.bounciness? or config.speed?) or (config.tension? or config.friction?) then return "spring"
    else throw Error "Unrecognized animation configuration"

  _removeReaction: ->
    return unless @isReactive
    @_reaction.removeListener @_reactionListener
    @_reactionListener = null
    @_reaction = null
    return

  _removeAnimated: ->
    return unless @isAnimated
    @_animated.stopAnimation()
    @_animated.removeListener @_animatedListener
    @_animatedListener = null
    @_animated = null
    return
