
{AnimatedProps} = require "Animated"
{ListenerMixin} = require "Event"

requireNativeComponent = require "requireNativeComponent"
React = require "react"
Type = require "Type"
sync = require "sync"

Component = require "./Component"

type = Type "NativeComponent"

type.inherits Component

type.defineArgs
  name: String.isRequired

type.initInstance ->
  mixin.apply this

type.overrideMethods

  build: ->

    name = @_name
    render = @_render ? do ->
      componentType = requireNativeComponent name
      return (props) -> React.createElement componentType, props

    @_render = ->
      props =
        if @_isMounting
        then @_animatedProps.__getAllValues()
        else @_animatedProps.__getNonNativeValues()
      props.ref = @_setChild
      render.call this, props

    @__super arguments

module.exports = type.build()

#
# Instance mixin
#

mixin = Component.Mixin()

mixin.defineValues

  _isMounting: no

  _child: null

  _queuedProps: null

  _animatedProps: -> AnimatedProps @constructor.propTypes

mixin.willMount ->
  @_isMounting = yes
  @_animatedProps.attach @props

mixin.didMount ->
  @_isMounting = no

mixin.defineListeners ->
  @_animatedProps.didSet @setNativeProps

mixin.willReceiveProps (nextProps) ->
  @_animatedProps.attach nextProps

mixin.willUnmount ->
  @_animatedProps.detach()

mixin.defineBoundMethods

  setNativeProps: (newProps) ->
    if @_child is null
    then @_queuedProps = newProps
    else @_child.setNativeProps newProps
    return

  _setChild: (view) ->

    if view and @_queuedProps
      view.setNativeProps @_queuedProps
      @_queuedProps = null

    @_child = view
    @_animatedProps.setAnimatedView view
    return
