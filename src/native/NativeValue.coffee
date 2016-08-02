
require "isDev"

{ AnimatedValue } = require "Animated"
{ mutable } = require "Property"

emptyFunction = require "emptyFunction"
isConstructor = require "isConstructor"
assertTypes = require "assertTypes"
assertType = require "assertType"
roundValue = require "roundValue"
clampValue = require "clampValue"
Progress = require "progress"
Reaction = require "reaction"
combine = require "combine"
assert = require "assert"
Tracer = require "tracer"
isType = require "isType"
Event = require "Event"
steal = require "steal"
Void = require "Void"
Null = require "Null"
Type = require "Type"
hook = require "hook"
Any = require "Any"
Nan = require "Nan"

NativeAnimation = require "./NativeAnimation"

type = Type "NativeValue"

type.argumentTypes =
  value: Any
  keyPath: String.Maybe

type.returnExisting (value) ->
  return value if value instanceof NativeValue

type.trace()

type.defineFrozenValues

  didSet: -> Event()

  didAnimationEnd: -> Event()

type.defineValues

  _clamp: no

  _round: null

  _keyPath: null

  _reaction: null

  _reactionListener: null

  _animated: null

  _animatedListener: null

  _retainCount: 1

type.defineReactiveValues

  _value: null

  _fromValue: null

  _toValue: null

  _animation: null

type.initInstance (value, keyPath) ->

  if isConstructor value, Reaction
    throw Error "NativeValue must create its own Reaction!"

  @_keyPath = keyPath
  if isType value, [ Object, Function.Kind ]
    @_attachReaction value
  else @value = value

type.defineGetters

  fromValue: -> @_fromValue

  toValue: -> @_toValue

  distance: -> @_toValue - @_fromValue

  isReactive: -> @_reaction isnt null

  isAnimated: -> @_animated isnt null

  isAnimating: -> @_animation isnt null

type.definePrototype

  keyPath:
    get: -> @_keyPath
    set: (keyPath) ->
      @_keyPath = keyPath
      @_reaction and @_reaction.keyPath = keyPath

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

  getValue: get: ->
    mutable.define this, "getValue",
      value: => @_value

  reaction:
    get: -> @_reaction
    set: (newValue, oldValue) ->
      return if newValue is oldValue
      if newValue is null
        @_detachReaction()
      else @_attachReaction newValue

  progress:
    get: -> @getProgress()
    set: (progress) ->
      @setProgress progress

type.defineMethods

  setValue: (newValue, config) ->

    assertType newValue, Number

    config ?= {}

    unless config.clamp?
      config.clamp = @_clamp

    unless config.round?
      config.round = @_round

    assertTypes config, configTypes.setValue if isDev

    if config.clamp is yes
      assert @_fromValue?, "Must have a 'fromValue' defined!"
      assert @_toValue?, "Must have a 'toValue' defined!"
      newValue = clampValue newValue, @_fromValue, @_toValue

    newValue = roundValue newValue, config.round if config.round?
    @value = newValue

  animate: (config) ->

    @_assertNonReactive()

    isDev and @_tracers.animate = Tracer "NativeValue::animate()"

    @stopAnimation()

    @_attachAnimated()

    isDev and assertTypes config, configTypes.animate

    onFinish = steal config, "onFinish", emptyFunction
    onEnd = steal config, "onEnd", emptyFunction

    @_animation = NativeAnimation
      animated: @_animated
      onUpdate: steal config, "onUpdate"
      onEnd: (finished) =>
        @_animation = null
        finished and onFinish()
        onEnd finished
        @didAnimationEnd.emit finished

    @_animation.start config
    return @_animation

  stopAnimation: ->
    animation = @_animation
    animation and animation.stop()
    return

  track: (nativeValue, config) ->

    assert not @_tracking, "Already tracking another value!"
    assertType nativeValue, NativeValue.Kind

    fromRange = config.fromRange ?= {}
    fromRange.fromValue ?= nativeValue._fromValue
    fromRange.toValue ?= nativeValue._toValue

    toRange = config.toRange ?= {}
    toRange.fromValue ?= @_fromValue
    toRange.toValue ?= @_toValue

    assertTypes config, configTypes.track if isDev

    onChange = (value) =>
      progress = Progress.fromValue value, fromRange
      @value = Progress.toValue progress, toRange

    # Update the value immediately.
    onChange nativeValue.value

    listener = nativeValue.didSet onChange
    return @_tracking = listener.start()

  stopTracking: ->
    tracking = @_tracking
    tracking.stop() if tracking
    return

  getProgress: (value, config) ->

    @_assertNonReactive()

    if isConstructor value, Object
      config = value
      value = @_value
    else
      config ?= {}
      value ?= @_value

    config.fromValue ?= if @_fromValue? then @_fromValue else @_value
    config.toValue ?= @_toValue

    assertType value, Number
    assertTypes config, configTypes.setProgress if isDev

    return Progress.fromValue value, config

  setProgress: (progress, config) ->

    @_assertNonReactive()

    config.fromValue ?= @_fromValue
    config.toValue ?= @_toValue

    assertType progress, Number
    assertTypes config, configTypes.setProgress if isDev

    value = Progress.toValue progress, config
    value = roundValue value, config.round if config.round?
    @value = value
    return

  willProgress: (config) ->

    @_assertNonReactive()

    assertTypes config, configTypes.setProgress if isDev

    @_fromValue = config.fromValue ?= @_value
    @_toValue = config.toValue
    return

  __attach: ->
    @_retainCount += 1

  __detach: ->
    @_retainCount -= 1
    return if @_retainCount > 0
    @_detachReaction()
    @_detachAnimated()

  _assertNonReactive: (reason) ->
    assert not @isReactive, reason

  _setValue: (newValue) ->
    return if @_value is newValue
    if isType newValue, Number
      assert not Nan.test(newValue), "Unexpected NaN value!"
    @_value = newValue
    @didSet.emit newValue

  _attachReaction: (options) ->

    if isConstructor options, Object
      options.keyPath ?= @keyPath
      reaction = Reaction.sync options

    else if options instanceof Function
      reaction = Reaction.sync { @keyPath, get: options }

    else return

    if @isReactive
      @_detachReaction()

    else
      @_detachAnimated()

    isDev and @_tracers.reaction = reaction._traceInit

    @_reaction = reaction

    listener = reaction.didSet (value) => @_setValue value
    @_reactionListener = listener.start()

    @_setValue reaction.value

  _attachAnimated: ->
    return if @_animated
    @_animated = new AnimatedValue @_value
    listener = @_animated.didSet (value) => @_setValue value
    @_animatedListener = listener.start()

  _detachReaction: ->
    return unless @isReactive
    @_reactionListener.stop()
    @_reactionListener = null
    @_reaction.stop()
    @_reaction = null
    return

  _detachAnimated: ->
    return unless @isAnimated
    @_animated.stopAnimation()
    @_animatedListener.stop()
    @_animatedListener = null
    @_animated = null
    return

module.exports = NativeValue = type.build()

if isDev

  configTypes = {}

  configTypes.animate =
    type: Function.Kind
    onUpdate: [ Function.Kind, Void ]
    onEnd: [ Function.Kind, Void ]
    onFinish: [ Function.Kind, Void ]

  configTypes.track =
    fromRange: Progress.Range
    toRange: Progress.Range

  configTypes.setValue =
    clamp: Boolean.Maybe
    round: [ Number, Null, Void ]

  configTypes.setProgress =
    fromValue: Number
    toValue: Number
    clamp: Boolean.Maybe
    round: Boolean.Maybe
