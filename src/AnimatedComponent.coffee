
{AnimatedProps} = require "Animated"
{ListenerMixin} = require "Event"

requireNativeComponent = require "requireNativeComponent"
React = require "react"
Type = require "Type"
sync = require "sync"

Component = require "./Component"

type = Type "AnimatedComponent"

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

  _animatedProps: ->
    props = AnimatedProps @constructor.propTypes
    return props.attach @props

mixin.willReceiveProps (nextProps) ->
  @_animatedProps.attach nextProps

mixin.defineListeners ->
  @_animatedProps.didSet @setNativeProps

mixin.willUnmount ->
  @_animatedProps.detach()

mixin.defineBoundMethods

  setNativeProps: (newProps) ->

    if @_child is null
      @_queuedProps = newProps
      return

    @_child.setNativeProps newProps
    return

  _setChild: (view) ->

    if view and @_queuedProps
      view.setNativeProps @_queuedProps
      @_queuedProps = null

    @_child = view
    return
