
{AnimatedProps} = require "Animated"

requireNativeComponent = require "requireNativeComponent"
React = require "react"
Type = require "Type"

Component = require "./Component"

type = Type "NativeComponent"

type.inherits Component

type.defineArgs [String]

type.initInstance ->
  mixin.apply this

type.overrideMethods

  build: ->

    name = @_name
    render = @_render or do ->
      componentType = requireNativeComponent name
      return (props) -> React.createElement componentType, props

    @_render = ->
      props =
        if @_isMounting
        then @_animatedProps.__getAllValues()
        else @_animatedProps.__getNonNativeValues()
      props.ref = @_setChild.bind this
      render.call this, props

    @__super arguments

module.exports = type.build()

#
# Instance mixin
#

mixin = Component.Mixin()

mixin.defineValues ->

  _isMounting: no

  _child: null

  _queuedProps: null

  _animatedProps: AnimatedProps @constructor.propTypes, @setNativeProps.bind this

mixin.willMount ->
  @_isMounting = yes
  @_animatedProps.attach @props
  return

mixin.didMount ->
  @_isMounting = no
  return

mixin.willReceiveProps (nextProps) ->
  @_animatedProps.attach nextProps
  return

mixin.willUnmount ->
  @_animatedProps.detach()
  return

mixin.defineMethods

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
