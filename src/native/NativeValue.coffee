
require "isDev"

{AnimatedValue} = require "Animated"
{Number} = require "Nan"

emptyFunction = require "emptyFunction"
mergeDefaults = require "mergeDefaults"
assertTypes = require "assertTypes"
assertType = require "assertType"
roundValue = require "roundValue"
clampValue = require "clampValue"
Progress = require "progress"
Reaction = require "reaction"
Tracker = require "tracker"
Tracer = require "tracer"
isType = require "isType"
Event = require "Event"
steal = require "steal"
Type = require "Type"
Any = require "Any"

NativeAnimation = require "./NativeAnimation"

ReactionOptions = Object.or Function.Kind

type = Type "NativeValue"

type.defineArgs
  value: Any
  keyPath: String

type.returnExisting (value) ->
  if isDev and value instanceof NativeValue
    throw Error "'value' cannot inherit from NativeValue!"

type.trace()

type.defineFrozenValues

  didSet: -> Event()

  didAnimationEnd: -> Event()

type.defineValues

  _dep: -> Tracker.Dependency()

  _value: null

  _keyPath: null

  _clamp: no

  _round: null

  _reaction: null

  _reactionListener: null

  _animated: null

  _animatedListener: null

  _retainCount: 0

type.defineReactiveValues

  _fromValue: null

  _toValue: null

  _animation: null

type.initInstance (value, keyPath) ->

  if isType value, Reaction
    throw Error "NativeValue must create its own Reaction!"

  @_keyPath = keyPath
  if ReactionOptions.test value
    @_attachReaction value
  else @value = value

type.defineGetters

  isReactive: -> @_reaction isnt null

  isAnimated: -> @_animated isnt null

  isAnimating: -> @_animation isnt null

  animation: -> @_animation

  velocity: -> if @_animation then @_animation.velocity else 0

  fromValue: -> @_fromValue

  toValue: -> @_toValue

  distance: -> @_toValue - @_fromValue

type.definePrototype

  value:
    get: ->
      Tracker.isActive and @_dep.depend()
      return @_value
    set: (newValue) ->
      if @isReactive
        throw Error "Cannot manually set 'value' when 'isReactive' is true!"
      if @isAnimated
        @_animated.setValue newValue
      else @_setValue newValue

  keyPath:
    get: -> @_keyPath
    set: (keyPath) ->
      @_keyPath = keyPath
      @_reaction and @_reaction.keyPath = keyPath

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

  setValue: (newValue, config = {}) ->

    unless config.clamp?
      config.clamp = @_clamp

    unless config.round?
      config.round = @_round

    isDev and
    assertTypes config, configTypes.setValue

    if config.clamp is yes

      if not @_fromValue?
        throw Error "Must define 'config.fromValue' or 'this.fromValue'!"

      if not @_toValue?
        throw Error "Must define 'config.toValue' or 'this.toValue'!"

      newValue = clampValue newValue, @_fromValue, @_toValue

    newValue = roundValue newValue, config.round if config.round?
    @value = newValue

  animate: (config) ->

    if @isReactive
      throw Error "Cannot call 'animate' when 'isReactive' is true!"

    isDev and
    @_tracers.animate = Tracer "NativeValue::animate()"

    @stopAnimation()

    @_attachAnimated()

    isDev and
    assertTypes config, configTypes.animate

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

  # TODO: Should this be deprecated?
  track: (nativeValue, config) ->

    assertType nativeValue, NativeValue.Kind

    if @_tracking
      throw Error "Already tracking another value!"

    fromRange = config.fromRange ?= {}
    fromRange.fromValue ?= nativeValue._fromValue
    fromRange.toValue ?= nativeValue._toValue

    toRange = config.toRange ?= {}
    toRange.fromValue ?= @_fromValue
    toRange.toValue ?= @_toValue

    isDev and
    assertTypes config, configTypes.track

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

    if isType value, Object
      config = value
      value = @_value
    else
      config ?= {}
      value ?= @_value

    config.fromValue ?= if @_fromValue? then @_fromValue else @_value
    config.toValue ?= @_toValue

    if isDev
      assertType value, Number
      assertTypes config, configTypes.setProgress

    return Progress.fromValue value, config

  setProgress: (progress, config) ->

    if @isReactive
      throw Error "Cannot call 'setProgress' when 'isReactive' is true!"

    if config
      mergeDefaults config, @_getRange()
    else config = @_getRange()

    if isDev
      assertType progress, Number
      assertTypes config, configTypes.setProgress

    value = Progress.toValue progress, config
    value = roundValue value, config.round if config.round?
    @value = value
    return

  willProgress: (config) ->

    isDev and
    assertTypes config, configTypes.setProgress

    @_fromValue = config.fromValue ?= @_value
    @_toValue = config.toValue
    return

  __attach: ->
    @_retainCount += 1
    return

  __detach: ->

    if @_retainCount > 1
      @_retainCount -= 1
      return

    if @_retainCount > 0
      @_retainCount -= 1

    @_detachReaction()
    @_detachAnimated()
    return

  _getRange: ->
    fromValue: @_fromValue
    toValue: @_toValue

  _setValue: (newValue) ->
    return if @_value is newValue
    @_value = newValue
    @_dep.changed()
    @didSet.emit newValue

  _attachReaction: (options) ->

    if isType options, Object
      options.keyPath ?= @keyPath
      reaction = Reaction.sync options

    else if options instanceof Function
      reaction = Reaction.sync { @keyPath, get: options }

    else return

    if @isReactive
      @_detachReaction()
    else
      @_detachAnimated()

    isDev and
    @_tracers.reaction = reaction._traceInit

    @_reaction = reaction
    @_setValue reaction.value
    @_reactionListener = reaction
      .didSet (value) => @_setValue value
      .start()

  _attachAnimated: ->
    return if @_animated
    @_animated = new AnimatedValue @_value
    @_animatedListener = @_animated
      .didSet (value) => @_setValue value
      .start()

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

isDev and
configTypes = do ->

  Null = require "Null"

  animate:
    type: Function.Kind
    onUpdate: Function.Kind.Maybe
    onFinish: Function.Kind.Maybe
    onEnd: Function.Kind.Maybe

  track:
    fromRange: Progress.Range
    toRange: Progress.Range

  setValue:
    clamp: Boolean.Maybe
    round: Number.or(Null).Maybe

  setProgress:
    fromValue: Number
    toValue: Number
    clamp: Boolean.Maybe
    round: Boolean.Maybe
