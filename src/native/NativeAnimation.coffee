
{ AnimatedValue } = require "Animated"

assertType = require "assertType"
immediate = require "immediate"
Progress = require "progress"
isType = require "isType"
Type = require "Type"
hook = require "hook"

# TODO: Merge this class into 'Animated'?
type = Type "NativeAnimation"

type.defineOptions
  animated: AnimatedValue.isRequired
  onUpdate: Function.Maybe
  onEnd: Function.Maybe

type.defineFrozenValues (options) ->

  _animated: options.animated

type.defineValues (options) ->

  _onUpdate: options.onUpdate

  _onEnd: options.onEnd

  _animation: null

type.defineGetters

  isActive: ->
    if anim = @_animation
      anim.isActive
    else no

  value: ->
    if anim = @_animation
      anim.value
    else null

  startValue: ->
    if anim = @_animation
      anim.startValue
    else null

  endValue: ->
    if anim = @_animation
      anim.endValue
    else null

  progress: ->
    if anim = @_animation
      anim.progress
    else 0

  velocity: ->
    if anim = @_animation
      return null unless isType anim.velocity, Number
      return anim.velocity
    return 0

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

    hook.before @_animation, "_onEnd", (finished) =>
      onUpdate and onUpdate.detach()
      @_onEnd finished
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
