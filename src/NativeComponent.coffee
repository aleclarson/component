
{AnimatedProps} = require "Animated"
{ListenerMixin} = require "Event"

requireNativeComponent = require "requireNativeComponent"
React = require "react"
Type = require "Type"
sync = require "sync"

Component = require "./Component"

type = Type "NativeComponent"

type.inherits Component.Builder

type.defineArgs
  name: String.isRequired

type.initInstance ->
  mixin.apply this

type.overrideMethods

  build: ->

    render = @_render

    if not render
      component = requireNativeComponent @_name
      render = (props) -> React.createElement component, props

    if not render
      throw Error "Missing native component: '#{@_name}'"

    @_render = ->
      props = @_animatedProps.__getValue()
      props.ref = @_setChild
      element = render.call this, props
      return element

    @__super arguments

module.exports = type.build()

#
# Instance mixin
#

mixin = Component.Mixin()

mixin.defineValues

  _child: null

  _queuedProps: null

  _animatedProps: -> AnimatedProps @constructor.propTypes

mixin.willMount ->
  @_animatedProps.attach @props

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
    @_animatedProps.setAnimatedView @_child
    return
