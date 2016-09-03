
ReactElement = require "ReactElement"
assertTypes = require "assertTypes"
assertType = require "assertType"
hook = require "hook"

ElementType = require "../utils/ElementType"
NativeProps = require "./NativeProps"
Component = require "../Component"

configTypes =
  render: Function
  propTypes: Object.Maybe

module.exports =
NativeComponent = (name, config) ->

  assertType name, String
  assertTypes config, configTypes

  type = Component "Native" + name

  if config.propTypes
    type.defineProps config.propTypes

  type.definePrototype
    _renderChild: ElementType config.render

  type.defineValues typeImpl.values
  type.defineBoundMethods typeImpl.boundMethods
  type.defineMountedListeners typeImpl.mountedListeners
  type.render typeImpl.render
  type.willReceiveProps typeImpl.willReceiveProps
  type.willUnmount typeImpl.willUnmount

  return type.build()

#
# The `typeImpl` interface is used
# by every NativeComponent factory!
#

typeImpl = {}

typeImpl.values =

  _child: null

  _queuedProps: null

  _nativeProps: ->
    NativeProps @props, @constructor.propTypes

typeImpl.boundMethods =

  setNativeProps: (newProps) ->

    if @_child is null
      @_queuedProps = newProps
      return

    @_child.setNativeProps newProps
    return

  _hookRef: (orig, view) ->

    if view and @_queuedProps
      view.setNativeProps @_queuedProps
      @_queuedProps = null

    @_child = view
    orig this
    return

typeImpl.mountedListeners = ->

  @_nativeProps.didSet @setNativeProps

#
# Rendering
#

typeImpl.render = ->
  props = @_nativeProps.values
  hook props, "ref", @_hookRef
  return @_renderChild props

typeImpl.willUnmount = ->
  @_nativeProps.detach()
  return

typeImpl.willReceiveProps = (nextProps) ->
  @_nativeProps.attach nextProps
  return
