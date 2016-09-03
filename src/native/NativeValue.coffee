
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

NativeAnimation = require "./NativeAnimation"

type = Type "NativeValue"

type.trace()

type.defineArgs
  value: null
  keyPath: String

isDev and
type.initArgs (value) ->

  if value instanceof NativeValue
    throw TypeError "'value' cannot inherit from NativeValue!"

  if value instanceof Reaction
    throw TypeError "'value' cannot inherit from Reaction!"

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
  @_keyPath = keyPath
  if isType(value, Function) or isType(value, Object)
    @_createReaction value
  else
    @value = value
  return

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
      if Tracker.isActive
        @_dep.depend()
      return @_value

    set: (newValue) ->

      if isDev and @isReactive
        throw Error "Reaction-backed values cannot be mutated!"

      if @isAnimated
        @_animated.setValue newValue
      else
        @_setValue newValue
      return

  keyPath:
    get: -> @_keyPath
    set: (keyPath) ->
      @_keyPath = keyPath
      @_reaction and @_reaction.keyPath = keyPath
      return

  reaction:
    get: -> @_reaction
    set: (newValue, oldValue) ->
      if newValue isnt oldValue
        @isReactive and @_deleteReaction()
        if newValue isnt null
          @_createReaction newValue
      return

  progress:
    get: -> @getProgress()
    set: (progress) ->
      @setProgress progress
      return

type.defineMethods

  setValue: (newValue, config = {}) ->

    unless config.clamp?
      config.clamp = @_clamp

    unless config.round?
      config.round = @_round

    isDev and
    assertTypes config, configTypes.setValue

    if config.clamp is yes

      if isDev and not @_fromValue?
        throw Error "Must define 'config.fromValue' or 'this.fromValue'!"

      if isDev and not @_toValue?
        throw Error "Must define 'config.toValue' or 'this.toValue'!"

      newValue = clampValue newValue, @_fromValue, @_toValue

    newValue = roundValue newValue, config.round if config.round?
    return @value = newValue

  _setValue: (newValue) ->
    if newValue isnt @_value
      @_value = newValue
      @_dep.changed()
      @didSet.emit newValue
    return

#
# Progress management
#

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

    if isDev and @isReactive
      throw Error "Reaction-backed values cannot be mutated!"

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

  _getRange: ->
    fromValue: @_fromValue
    toValue: @_toValue

#
# Memory management
#

  __attach: ->

    if @_retainCount is 0
      @isReactive and @_startReaction()

    @_retainCount += 1
    return this

  __detach: ->

    if isDev and @_retainCount is 0
      throw Error "Must call '__attach' for every call to '__detach'!"

    if @_retainCount > 1
      @_retainCount -= 1
      return

    if @_retainCount > 0
      @_retainCount -= 1

    @_detachReaction()
    @_detachAnimated()
    return

#
# Reaction management
#

  _createReaction: (options) ->
    assertType options, Object.or Function

    if isType options, Function
      @_reaction = Reaction {@keyPath, get: options}
    else
      options.keyPath ?= @keyPath
      @_reaction = Reaction options
    return

  _startReaction: ->

    if isDev and not @isReactive
      throw Error "Must call '_createReaction' before '_startReaction'!"

    @_reactionListener = @_reaction
      .didSet (value) => @_setValue value
      .start()

    @_reaction.start()
    return

  _deleteReaction: ->

    if isDev and not @isReactive
      throw Error "Must call '_createReaction' before '_deleteReaction'!"

    @_reactionListener.stop()
    @_reactionListener = null

    @_reaction.stop()
    @_reaction = null
    return

#
# Animation management
#

  animate: (config) ->

    if isDev and @isReactive
      throw Error "Reaction-backed values cannot be mutated!"

    @stopAnimation()
    @_createAnimated()

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
    if @_animation
      @_animation.stop()
    return

  _createAnimated: ->
    return if @isAnimated
    @_animated = new AnimatedValue @_value
    @_animatedListener = @_animated
      .didSet (value) => @_setValue value
      .start()

  _deleteAnimated: ->
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
    type: Type
    onUpdate: Function.Maybe
    onFinish: Function.Maybe
    onEnd: Function.Maybe

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
