
{Animation, AnimatedValue} = require "Animated"
{Number} = require "Nan"

emptyFunction = require "emptyFunction"
assertType = require "assertType"
clampValue = require "clampValue"
Reaction = require "Reaction"
Tracker = require "tracker"
isType = require "isType"
Event = require "Event"
isDev = require "isDev"
steal = require "steal"
Type = require "Type"

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

type.defineFrozenValues ->

  didSet: Event {async: no}

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

type.definePrototype

  value:

    get: ->
      @_dep.depend() if Tracker.isActive
      @_value

    set: (newValue) ->

      if isDev and @isReactive
        throw Error "Reaction-backed values cannot be mutated!"

      if @isAnimated
      then @_animated.setValue newValue
      else @_set newValue

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

type.defineMethods

  get: -> @value

  set: (newValue) ->
    @value = newValue

  createPath: (values) ->
    assertType values, Array
    path = AnimationPath()
    path.listener = @didSet (newValue) ->
      index = -1
      maxIndex = values.length - 1
      while newValue >= values[++index]
        break if index is maxIndex
      startValue = values[index - 1]
      if startValue is undefined
        index += 1
        progress = 0
      else
        progress = (newValue - startValue) / (values[index] - startValue)
        progress = clampValue progress, 0, 1
      path._update index - 1, progress
      return
    return path

  _set: (newValue) ->
    if newValue isnt @_value
      @_value = newValue
      @_dep.changed()
      @didSet.emit newValue
    return

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
      .didSet (value) => @_set value
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

    onUpdate = steal config, "onUpdate"
    isDev and assertType onUpdate, Function.Maybe

    onFinish = steal config, "onFinish", emptyFunction
    isDev and assertType onFinish, Function

    onEnd = steal config, "onEnd", emptyFunction
    isDev and assertType onEnd, Function

    if @isAnimated
    then @stopAnimation()
    else @_createAnimated()

    if onUpdate
      updater = @_animated
        .didSet onUpdate
        .start()

    type = steal config, "type"
    isDev and assertType type, String.or Function.Kind

    if isType type, String
      if isDev and not Animation.types[type]
        throw Error "Invalid animation type: '#{type}'"
      type = Animation.types[type]

    animation = type config
    isDev and assertType animation, Animation.Kind

    @_animation = animation
    @_animated.animate animation, (finished) =>
      @_animation = null
      updater and updater.detach()
      finished and onFinish()
      onEnd finished

  stopAnimation: ->
    if @_animation
      @_animation.stop()
    return

  _createAnimated: ->
    @_animated = new AnimatedValue @_value
    @_animatedListener = @_animated
      .didSet (value) => @_set value
      .start()

  _deleteAnimated: ->
    return unless @isAnimated
    @_animated.stopAnimation()
    @_animatedListener.stop()
    @_animatedListener = null
    @_animated = null
    return

module.exports = NativeValue = type.build()

# This class is used by `NativeValue::createPath` for easier
# animation along a path in response to another value changing.
AnimationPath = do ->

  type = Type "AnimationPath"

  type.defineValues ->

    _paths: []

  type.defineMethods

    attach: (value, nodes) ->
      assertType value, NativeValue
      assertType nodes, Array

      path = {}
      index = -1

      # Connect the dots of each animation path.
      for node in nodes

        if path.endValue isnt undefined
          path = {startValue: path.endValue}

        if path.startValue is undefined
          assertType node, Number
          path.startValue = node

        else if typeof node is "function"
          path.easing = node

        else
          assertType node, Number
          path.endValue = node
          path.easing ?= emptyFunction.thatReturnsArgument
          @_attach ++index, value, path

      if path.endValue is undefined
        throw Error "Animation path is missing an 'endValue'!"

      return this

    _attach: (index, value, { startValue, endValue, easing }) ->
      distance = endValue - startValue
      @_paths.push [] if @_paths.length <= index
      @_paths[index].push (progress) ->
        value.set startValue + distance * easing progress

    _update: (index, progress) ->
      for update in @_paths[index]
        update progress
      return

  return type.build()
