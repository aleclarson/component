
{ throwFailure } = require "failure"

ReactElement = require "ReactElement"
assertTypes = require "assertTypes"
assertType = require "assertType"

NativeProps = require "./Props"
Component = require "../Component"

configTypes =
  render: Function
  propTypes: Object

module.exports =
NativeComponent = (name, config) ->

  assertType name, String
  assertTypes config, configTypes

  type = Component "Native" + name

  type.definePrototype
    _propTypes: { value: config.propTypes }
    _renderChild: ReactElement.createElement.bind null, config.render

  type.defineValues typeImpl.values
  type.defineListeners typeImpl.listeners
  type.render typeImpl.render
  type.willUnmount typeImpl.willUnmount

  return type.build()

typeImpl = {}

typeImpl.values =

  child: null

  _queuedProps: null

  _nativeProps: ->
    NativeProps @props, @_propTypes

typeImpl.render = ->
  props = @_nativeProps.values
  props.ref = onRef.bind this
  @_renderChild props

typeImpl.listeners = ->

  @_nativeProps.didSet (newProps) =>
    if @child isnt null
      @child.setNativeProps newProps
    else @_queuedProps = newProps

typeImpl.willUnmount = ->
  @_nativeProps.detach()

#
# Helpers
#

onRef = (view) ->
  @child = view
  if view and @_queuedProps
    @child.setNativeProps @_queuedProps
    @_queuedProps = null
  return
