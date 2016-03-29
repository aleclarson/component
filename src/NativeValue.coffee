
# TODO Batch synchronous changes in an appropriate timeframe (eg: 16ms).

{ isType, validateTypes, assertType, assert, Maybe } = require "type-utils"

emptyFunction = require "emptyFunction"
Immutable = require "immutable"
Animated = require "Animated"
Progress = require "progress"
Reaction = require "reaction"
Factory = require "factory"
combine = require "combine"
Event = require "event"
steal = require "steal"
isDev = require "isDev"
sync = require "sync"
hook = require "hook"

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
        return if newValue is oldValue
        @_attachReaction newValue

  initFrozenValues: ->

    didSet: Event()

    didAnimationEnd: Event()

  initValues: (value, keyPath) ->

    _keyPath: keyPath

    _inputRange: null

    _easing: null

    _reaction: null

    _reactionListener: null

    _animated: null

    _animatedListener: null

    _animateStackTrace: null

  initReactiveValues: ->

    _animating: no

    _fromValue: null

    _toValue: null

    _value: null

  init: (value, keyPath) ->

    if isType value, Reaction
      value.keyPath ?= keyPath
      @reaction = value

    else if isType value, Function.Kind
      @reaction = Reaction.sync { keyPath, get: value } # , autoStart: no }

    else if isType value, Object
      value.keyPath ?= keyPath
      # value.autoStart ?= no
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

    validateTypes config,
      onUpdate: Maybe Function.Kind
      onEnd: Maybe Function.Kind
      onFinish: Maybe Function.Kind

    @stopAnimation()

    @_attachAnimated()

    @_animateStackTrace = Error() if isDev

    onUpdate = steal config, "onUpdate"
    if onUpdate
      listener = @_animated.addListener (result) =>
        onUpdate result.value

    onEnd = steal config, "onEnd", emptyFunction
    onFinish = steal config, "onFinish", emptyFunction

    @_fromValue = @_value
    @_toValue = config.toValue

    # Create the Animation and start it.
    type = @_detectAnimationType config
    animation = Animated[type] @_animated, config
    animation.start()

    # If the Animation finishes instantly, this value is undefined.
    animation = @_animated._animation
    unless animation
      @_animated.removeListener listener if onUpdate
      finished = (@_toValue is undefined) or (@_toValue is @_value)
      @_onAnimationEnd finished, onFinish, onEnd
      return

    @_animating = yes
    hook.after animation, "__onEnd", (_, result) =>
      @_animating = no
      @_animated.removeListener listener if onUpdate?
      result.finished = @_value is @_toValue if @_toValue?
      @_onAnimationEnd result.finished, onFinish, onEnd

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

    progress = steal options, "progress"

    progress = @_applyInputRange progress if @_inputRange?

    progress = @_easing progress if @_easing?

    @value = Progress.toValue progress, options

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
    assertType newValue, @type, { stack: @_animateStackTrace } if @type isnt undefined
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
    @_reaction = reaction
    @_reaction.keyPath ?= @keyPath
    @_reactionListener = @_reaction.didSet (newValue) =>
      @_setValue newValue
    @_setValue reaction.value

  _attachAnimated: ->
    return if @_animated?
    @_animated = new Animated.Value @_value
    listener = ({ value }) => @_setValue value
    @_animatedListener = @_animated.addListener listener

  _detectAnimationType: (config) ->
    return "timing" if config.duration isnt undefined
    return "decay" if config.deceleration isnt undefined
    return "spring" if (config.speed isnt undefined) or (config.tension isnt undefined)
    throw Error "Unrecognized animation configuration"

  _onAnimationEnd: (finished, onFinish, onEnd) ->
    onFinish() if finished
    onEnd finished
    @didAnimationEnd.emit finished

  _detachReaction: ->
    return unless @isReactive
    @_reactionListener.stop()
    @_reactionListener = null
    @_reaction = null
    return

  _detachAnimated: ->
    return unless @isAnimated
    @_animated.stopAnimation()
    @_animated.removeListener @_animatedListener
    @_animatedListener = null
    @_animated = null
    return
