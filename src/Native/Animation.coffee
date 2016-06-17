
{ AnimatedValue } = require "Animated"

getArgProp = require "getArgProp"
Progress = require "progress"
isType = require "isType"
Type = require "Type"
hook = require "hook"

# TODO: Merge this class into 'Animated'?
type = Type "NativeAnimation"

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
    if isType(velocity, Number) then velocity else 0

type.defineFrozenValues

  _animated: getArgProp "animated"

  _animation: (options) ->
    options.type options.config

type.defineValues

  _fromValue: -> @value

  _toValue: getArgProp "config.toValue"

  _onUpdate: getArgProp "onUpdate"

  _onEnd: getArgProp "onEnd"

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
