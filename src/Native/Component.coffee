
{ throwFailure } = require "failure"

ReactElement = require "ReactElement"
assertType = require "assertType"

NativeProps = require "./Props"
Component = require "../Component"

module.exports =
NativeComponent = (name, render) ->

  assertType name, String
  assertType render, Function

  type = Component "Native" + name

  type.definePrototype
    _render: render

  if render.propTypes
    type.didBuild (type) ->
      type.propTypes = render.propTypes

  type.defineValues typeImpl.values
  type.defineMethods typeImpl.methods
  type.defineListeners typeImpl.listeners
  type.willUnmount typeImpl.willUnmount

  return type.build()

typeImpl = {}

typeImpl.values =

  child: null

  _queuedProps: null

  _nativeProps: ->
    NativeProps @props, @_render.propTypes

typeImpl.methods =

  render: ->
    props = @_nativeProps.values
    props.ref = (view) => @_onRef view
    ReactElement.createElement @_render, props

  _onRef: (view) ->
    @child = view
    if view and @_queuedProps
      @child.setNativeProps @_queuedProps
      @_queuedProps = null

typeImpl.listeners = ->

  @_nativeProps.didSet (newProps) =>

    guard =>
      if @child isnt null
        @child.setNativeProps newProps
      else @_queuedProps = newProps

    .fail (error) =>
      throwFailure error, { component: this, newProps }

typeImpl.willUnmount = ->
  @_nativeProps.detach()
