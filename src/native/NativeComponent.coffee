
emptyFunction = require "emptyFunction"
assertType = require "assertType"
hook = require "hook"

PropValidator = require "../utils/PropValidator"
ElementType = require "../utils/ElementType"
NativeProps = require "./NativeProps"
Component = require "../Component"

configTypes =
  render: Function
  propTypes: Object.Maybe

NativeComponent = (name, {render, propTypes}) ->

  assertType name, String
  assertType render, Function
  assertType propTypes, Object.Maybe

  type = Component "Native" + name

  if propTypes
    props = PropValidator propTypes
    type.didBuild (type) ->
      type.propTypes = props.types
      type.propDefaults = props.defaults
      return

  type.definePrototype
    _renderChild: ElementType render,
      if propTypes then props.validate
      else emptyFunction.thatReturnsArgument

  type[key] impl for key, impl of typeImpl
  return type.build()

module.exports = NativeComponent

#
# The `typeImpl` interface is used
# by every NativeComponent factory!
#

typeImpl = {}

typeImpl.defineValues =

  _child: null

  _queuedProps: null

  _nativeProps: ->
    NativeProps @props, @constructor.propTypes

typeImpl.defineBoundMethods =

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

typeImpl.defineMountedListeners = ->
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
