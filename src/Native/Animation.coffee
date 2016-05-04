
{ AnimatedValue } = require "Animated"

Progress = require "progress"
Type = require "Type"
hook = require "hook"

type = Type "Animation"

type.optionTypes =
  animated: AnimatedValue
  type: Function.Kind
  config: Object
  onUpdate: Function.Maybe
  onEnd: Function.Maybe

type.defineProperties

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

type.defineFrozenValues

  _animated: (options) -> options.animated

  _animation: (options) -> new options.type options.config

type.defineValues

  _fromValue: -> @value

  _toValue: (options) -> options.config.toValue

  _onUpdate: (options) -> options.onUpdate

  _onEnd: (options) -> options.onEnd

type.initInstance ->

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

type.defineMethods

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

module.exports = type.build()
