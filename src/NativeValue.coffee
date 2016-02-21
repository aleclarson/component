
# TODO Batch synchronous changes in an appropriate timeframe (eg: 16ms).

{ isType, validateTypes, assertType, assert, Void } = require "type-utils"
{ sync, async } = require "io"

reportFailure = require "report-failure"
emptyFunction = require "emptyFunction"
Listenable = require "listenable"
Immutable = require "immutable"
Animated = require "Animated"
Reaction = require "reaction"
Factory = require "factory"
combine = require "combine"
steal = require "steal"

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

    getValue:
      lazy: -> => @_value

    toValue:
      get: -> @_animated?._animation?._toValue or @_value

    progress:
      get: -> @getProgress()
      set: (progress) ->
        @setProgress progress

    isAnimated:
      get: -> @_animated?

    isAnimating:
      get: -> @_animating

    isReactive:
      get: -> @_reaction?

  initValues: (value, keyPath) ->
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
      @setReaction value

    else if isType value, Function.Kind
      @setReaction Reaction.sync { keyPath, get: value, autoStart: no }

    else if isType value, Object
      value.keyPath ?= keyPath
      value.autoStart ?= no
      @setReaction Reaction.sync value

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

  setReaction: (reaction) ->
    return @_removeReaction() unless reaction?
    assertType reaction, Reaction
    if @isReactive then @_removeReaction()
    else @_removeAnimated()
    @_reaction = reaction
    @_reaction.keyPath ?= @keyPath
    @_reactionListener = @_setValue.bind this
    @_reactionListener reaction.value
    @_reaction.addListener @_reactionListener

  animate: (config) ->

    assert not @isReactive,
      reason: "Cannot call 'animate' when 'isReactive' is true!"
      nativeValue: this

    @_initAnimatedValue()

    if config.effect?
      effect = steal config, "effect"
      combine config, effect

    @_fromValue = @_value
    @_toValue = config.toValue

    onEnd = steal config, "onEnd", emptyFunction
    assertType onEnd, Function, { config, onEnd, emptyFunction, key: "onEnd" }

    onFinish = steal config, "onFinish", emptyFunction
    assertType onFinish, Function, { config, key: "onFinish" }

    method = @_getAnimatedMethod config
    animation = Animated[method] @_animated, config
    animation.start()

    if @_animated._animation?
      @_animating = yes
      @onAnimationEnd (finished) =>
        @_animating = no
        onFinish() if finished
        onEnd finished

    else
      finished = @_value is @_toValue
      onFinish() if finished
      onEnd finished

    return

  stopAnimation: (callback) ->
    unless @_animated?
      callback? @_value
    else if @_animated._animation?
      @_animated.stopAnimation callback
    else
      callback? @_animated.__getValue()
    return

  onAnimationUpdate: (callback) ->
    assertType callback, Function
    animated = @_animated
    return unless animated?._animation?
    id = animated.addListener (result) -> callback result.value
    @onAnimationEnd -> animated.removeListener id
    return

  onAnimationEnd: (callback) ->
    assertType callback, Function
    animation = @_animated?._animation
    return callback yes unless animation?
    onEnd = animation.__onEnd
    animation.__onEnd = (result) ->
      onEnd.call this, result
      callback result.finished
    return

  onAnimationFinish: (callback) ->
    @onAnimationEnd (finished) ->
      callback() if finished

  getProgress: (config = {}) ->

    assert not @isReactive,
      reason: "Cannot call 'getProgress' when 'isReactive' is true!"
      nativeValue: this

    assertType config, Object

    validateTypes config,
      at: [ Number, Void ]
      to: [ Number, Void ]
      from: [ Number, Void ]
      clamp: [ Boolean, Void ]

    { at, to, from, clamp } = config

    at ?= @_value
    to ?= @_toValue
    from ?= @_fromValue
    from ?= @_value

    assert to?
    assert from?

    progress =
      if to is from then 1
      else (at - from) / (to - from)

    if clamp then Math.max 0, Math.min 1, progress
    else progress

  setProgress: (config) ->

    assert not @isReactive,
      reason: "Cannot call 'setProgress' when 'isReactive' is true!"
      nativeValue: this

    if isType config, Number
      config = { progress: config }

    config.from ?= @_fromValue
    config.to ?= @_toValue

    validateTypes config,
      progress: Number
      from: Number
      to: Number

    { progress, from, to } = config

    progress = @_applyInputRange progress if @_inputRange?

    progress = @_easing progress if @_easing?

    assertType progress, Number

    @value = from + progress * (to - from)

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
