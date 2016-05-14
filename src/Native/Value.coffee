
require "isDev"

{ AnimatedValue } = require "Animated"

emptyFunction = require "emptyFunction"
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
Maybe = require "Maybe"
Event = require "event"
Null = require "Null"
Type = require "Type"
sync = require "sync"
Any = require "Any"

Animation = require "./Animation"

if isDev

  configTypes = {}

  configTypes.animate =
    type: Function.Kind
    onUpdate: Maybe Function.Kind
    onEnd: Maybe Function.Kind
    onFinish: Maybe Function.Kind

  configTypes.track =
    fromRange: Progress.Range
    toRange: Progress.Range

  configTypes.setValue =
    clamp: Boolean.Maybe
    round: Maybe [ Number, Null ]

  configTypes.setProgress =
    fromValue: Number
    toValue: Number
    clamp: Boolean.Maybe
    round: Boolean.Maybe

type = Type "NativeValue"

type.argumentTypes =
  value: Any
  keyPath: String.Maybe

type.returnExisting (value) ->
  return value if isType value, NativeValue.Kind

type.defineProperties

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

  isReactive: get: ->
    @_reaction?

  reaction:
    get: -> @_reaction
    set: (newValue, oldValue) ->
      return if newValue is oldValue
      if newValue is null
        @_detachReaction()
      else @_attachReaction newValue

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
      @setProgress progress

  isAnimated: get: ->
    @_animated isnt null

  isAnimating: get: ->
    @_animation isnt null

type.exposeGetters [
  "animation"
]

type.defineFrozenValues

  didSet: -> Event()

  didAnimationEnd: -> Event { maxRecursion: 10 }

type.defineValues

  clamp: no

  round: null

  _keyPath: null

  _reaction: null

  _reactionListener: null

  _animated: null

  _animation: null

  _animatedListener: null

  _retainCount: 1

if isDev
  type.defineValues
    _traceInit: -> Tracer "NativeValue()"
    _traceAnimate: null
    _traceReaction: null

type.defineReactiveValues

  _value: null

  _fromValue: null

  _toValue: null

type.initInstance (value, keyPath) ->

  if isType value, Reaction
    throw Error "NativeValue must create its own Reaction!"

  else if isType value, Function.Kind
    @reaction = Reaction.sync { keyPath, get: value }
    return

  @_keyPath = keyPath
  @value = value

type.defineMethods

  setValue: (newValue, config) ->

    assertType newValue, Number

    config ?= {}

    unless config.clamp?
      config.clamp = @clamp

    unless config.round?
      config.round = @round

    assertTypes config, configTypes.setValue if isDev

    if config.clamp is yes
      assert @_fromValue?, "Must have a 'fromValue' defined!"
      assert @_toValue?, "Must have a 'toValue' defined!"
      newValue = clampValue newValue, @_fromValue, @_toValue

    newValue = roundValue newValue, config.round if config.round?
    @value = newValue

  animate: (config) ->

    @_assertNonReactive()

    @_traceAnimate = Tracer "When the Animation was created" if isDev

    @_animation.stop() if @_animation

    @_attachAnimated()

    assertTypes config, configTypes.animate if isDev

    callbacks =
      onUpdate: steal config, "onUpdate"
      onFinish: steal config, "onFinish", emptyFunction
      onEnd: steal config, "onEnd", emptyFunction

    onEnd = (finished) =>
      @_animation = null
      callbacks.onFinish() if finished
      callbacks.onEnd finished
      @didAnimationEnd.emit finished

    @_animation = Animation {
      animated: @_animated
      type: steal config, "type"
      config
      onUpdate: callbacks.onUpdate
      onEnd
    }

  stopAnimation: ->
    animation = @_animation
    animation.stop() if animation
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

    @_tracking = nativeValue.didSet (value) =>
      progress = Progress.fromValue value, fromRange
      @value = Progress.toValue progress, toRange

    # Update the value immediately.
    @_tracking._onEvent nativeValue.value

    # Clean up even if the listener was
    # stopped without calling 'stopTracking()'.
    @_tracking._onDefuse = =>
      @_tracking = null

    return @_tracking

  stopTracking: ->
    tracking = @_tracking
    tracking.stop() if tracking
    return

  getProgress: (value, config) ->

    @_assertNonReactive()

    if isType value, Object
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
    @_value = newValue
    @didSet.emit newValue

  _attachReaction: (reaction) ->

    if isType reaction, Reaction
      throw Error "NativeValue must create its own Reaction!"

    if isType reaction, Function.Kind
      reaction = Reaction.sync { get: reaction }

    else if isType reaction, Object
      reaction = Reaction.sync reaction

    else return

    if @isReactive
      @_detachReaction()
    else @_detachAnimated()

    @_traceReaction = reaction._traceInit if isDev

    @_reaction = reaction
    @_reaction.keyPath ?= @keyPath
    @_reactionListener = @_reaction.didSet (newValue) => @_setValue newValue
    @_setValue reaction.value

  _attachAnimated: ->
    return if @_animated
    @_animated = new AnimatedValue @_value
    @_animatedListener = @_animated.didSet (value) => @_setValue value

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
