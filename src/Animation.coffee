
{ AnimatedValue } = require "Animated"

Progress = require "progress"
Factory = require "factory"
hook = require "hook"

module.exports = Factory "Animation",

  optionTypes:
    animated: AnimatedValue
    type: Function.Kind
    config: Object
    onUpdate: Function.Maybe
    onEnd: Function.Maybe

  customValues:

    isActive: get: ->
      @_animation.__active

    value: get: ->
      @_animated.__getValue()

    fromValue: get: ->
      @_fromValue

    toValue: get: ->
      @_toValue

    progress: get: ->
      Progress.fromValue @value,
        fromValue: @_fromValue
        toValue: @_toValue
        clamp: yes

    velocity: get: ->
      velocity = @_animation._curVelocity
      if (isType velocity, Number) then velocity else 0

  initFrozenValues: (options) ->

    _animated: options.animated

    _animation: new options.type options.config

  initValues: (options) ->

    _fromValue: @value

    _toValue: options.config.toValue

    _onUpdate: options.onUpdate

    _onEnd: options.onEnd

  init: ->

    # Attach the value listener.
    onUpdate = @_animated.didSet (result) =>
      @_onUpdate result if @_onUpdate

    # Start the animation.
    @_animated.animate @_animation

    # Detect instant animations.
    unless @isActive
      onUpdate.stop() if onUpdate
      @_onEnd (@_toValue is undefined) or (@_toValue is @value)
      return

    hook.before @_animation, "__onEnd", (result) =>
      onUpdate.stop() if onUpdate
      @_onEnd result.finished

  stop: ->
    return unless @isActive
    @_animated.stopAnimation()
    return

  finish: ->
    return unless @isActive
    if @_toValue isnt undefined
      @_animated.setValue @_toValue
    else @_animated.stopAnimation()
    return
