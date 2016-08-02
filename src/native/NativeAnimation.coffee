
{ AnimatedValue } = require "Animated"

assertType = require "assertType"
immediate = require "immediate"
fromArgs = require "fromArgs"
Progress = require "progress"
isType = require "isType"
Type = require "Type"
hook = require "hook"

# TODO: Merge this class into 'Animated'?
type = Type "NativeAnimation"

type.defineOptions
  animated: AnimatedValue.isRequired
  config: Object
  onUpdate: Function.Maybe
  onEnd: Function.Maybe

type.defineFrozenValues

  _animated: fromArgs "animated"

type.defineValues

  _fromValue: -> @value

  _toValue: fromArgs "config.toValue"

  _onUpdate: fromArgs "onUpdate"

  _onEnd: fromArgs "onEnd"

  _animation: null

type.defineGetters

  isActive: -> @_animation.__active

  value: -> @_animated.__getValue()

  fromValue: -> @_fromValue

  toValue: -> @_toValue

  progress: ->
    Progress.fromValue @value,
      fromValue: @_fromValue
      toValue: @_toValue
      clamp: yes

  velocity: ->
    velocity = @_animation.velocity
    return 0 if not isType velocity, Number
    return velocity

type.defineMethods

  start: (config) ->

    assertType config, Object
    assertType config.type, Function.Kind

    if @_onUpdate
      onUpdate = @_onUpdate and @_animated.didSet @_onUpdate
      onUpdate.start()

    @_animation = config.type config
    @_animated.animate @_animation

    # Detect instant animations.
    if not @isActive
      onUpdate and onUpdate.detach()
      immediate => @_onEnd yes
      return

    hook.before @_animation, "__onEnd", (result) =>
      onUpdate and onUpdate.detach()
      @_onEnd result.finished

    return

  stop: ->
    return unless @isActive
    @_animated.stopAnimation()
    @_animation = null
    return

  finish: ->
    return unless @isActive
    if @_toValue isnt undefined
      @_animated.setValue @_toValue
    else @_animated.stopAnimation()
    return

module.exports = type.build()
