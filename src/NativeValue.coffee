
require "isDev"

{ isType, validateTypes, assertType, assert, Maybe, Null } = require "type-utils"
{ AnimatedValue } = require "Animated"

emptyFunction = require "emptyFunction"
roundValue = require "roundValue"
clampValue = require "clampValue"
Progress = require "progress"
Reaction = require "reaction"
Factory = require "factory"
combine = require "combine"
Tracer = require "tracer"
Event = require "event"
steal = require "steal"
sync = require "sync"

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
    round: [ Null, Number.Maybe ]

  configTypes.setProgress =
    fromValue: Number
    toValue: Number
    clamp: Boolean.Maybe
    round: [ Null, Number.Maybe ]

module.exports =
NativeValue = Factory "NativeValue",

  initArguments: (value, keyPath) ->
    assertType keyPath, String.Maybe, "keyPath"
    arguments

  getFromCache: (value) ->
    if isType value, NativeValue.Kind then value else undefined

  customValues:

    keyPath:
      get: -> @_keyPath
      set: (keyPath) ->
        @_keyPath = keyPath
        @_reaction?.keyPath = keyPath

    value:
      get: -> @_value
      set: (newValue) ->

        @_assertNonReactive()

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
        @setProgress progress

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
        if newValue is null then @_detachReaction()
        else @_attachReaction newValue

  initFrozenValues: ->

    didSet: Event()

    didAnimationEnd: Event { maxRecursion: 10 }

  initValues: ->

    clamp: no

    round: null

    _keyPath: null

    _reaction: null

    _reactionListener: null

    _animated: null

    _animation: null

    _animatedListener: null

    _tracer: emptyFunction

    _retainCount: 1

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
      @_keyPath = keyPath
      @value = value

  setValue: (newValue, config) ->

    assertType newValue, Number

    config ?= {}

    unless config.clamp?
      config.clamp = @clamp

    unless config.round?
      config.round = @round

    validateTypes config, configTypes.setValue if isDev

    if config.clamp is yes
      assert @_fromValue?, "Must have a 'fromValue' defined!"
      assert @_toValue?, "Must have a 'toValue' defined!"
      newValue = clampValue newValue, @_fromValue, @_toValue

    newValue = roundValue newValue, config.round if config.round?
    @value = newValue

  animate: (config) ->

    @_assertNonReactive()

    @_tracer = Tracer "When the Animation was created" if isDev

    @_animation.stop() if @_animation

    @_attachAnimated()

    validateTypes config, configTypes.animate if isDev

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

  track: (nativeValue, config) ->

    assert not @_tracking, "Already tracking another value!"
    assertType nativeValue, NativeValue.Kind

    fromRange = config.fromRange ?= {}
    fromRange.fromValue ?= nativeValue._fromValue
    fromRange.toValue ?= nativeValue._toValue

    toRange = config.toRange ?= {}
    toRange.fromValue ?= @_fromValue
    toRange.toValue ?= @_toValue

    validateTypes config, configTypes.track if isDev

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
    @_tracking.stop() if @_tracking
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
    validateTypes config, configTypes.setProgress if isDev

    return Progress.fromValue value, config

  setProgress: (progress, config) ->

    @_assertNonReactive()

    config ?= {}
    config.fromValue ?= @_fromValue
    config.toValue ?= @_toValue
    config.clamp ?= @clamp
    config.round ?= @round

    assertType progress, Number
    validateTypes config, configTypes.setProgress if isDev

    value = Progress.toValue progress, config
    value = roundValue value, config.round if config.round?
    @value = value
    return

  willProgress: (config) ->

    @_assertNonReactive()

    validateTypes config, configTypes.setProgress if isDev

    if config.clamp isnt undefined
      @clamp = config.clamp

    if config.round isnt undefined
      @round = config.round

    @_fromValue = config.fromValue ?= @_value
    @_toValue = config.toValue
    return

  __attach: ->
    @_retainCount += 1
    return

  __detach: ->
    @_retainCount -= 1
    return if @_retainCount > 0
    @_detachReaction()
    @_detachAnimated()
    return

  _assertNonReactive: (reason) ->
    assert not @isReactive, reason

  _setValue: (newValue) ->
    return if @_value is newValue
    @_value = newValue
    @didSet.emit newValue

  _attachReaction: (reaction) ->

    unless isType reaction, Reaction
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
    @_animatedListener = @_animated.didSet (value) =>
      @_setValue value

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
