
{ throwFailure } = require "failure"

ReactElement = require "ReactElement"
assertType = require "assertType"

NativeProps = require "./Props"
Component = require "../Component"

module.exports =
NativeComponent = (render) ->

  assertType render, Function

  type = Component()

  type.definePrototype
    _render: render

  type.didBuild (type) ->
    type.propTypes = render.propTypes

  type.defineValues instanceValues
  type.defineMethods instanceMethods
  type.defineListeners defineListeners
  type.willUnmount willUnmount

  return type.build()

instanceValues =

  child: null

  _queuedProps: null

  _nativeProps: ->
    NativeProps @props, @_render.propTypes

instanceMethods =

  render: ->
    props = @_nativeProps.values
    props.ref = (view) => @_onRef view
    ReactElement.createElement @_render, props

  _onRef: (view) ->
    @child = view
    if view and @_queuedProps
      @child.setNativeProps @_queuedProps
      @_queuedProps = null

defineListeners = ->

  @_nativeProps.didSet (newProps) =>

    guard =>
      if @child isnt null
        @child.setNativeProps newProps
      else @_queuedProps = newProps

    .fail (error) =>
      throwFailure error, { component: this, newProps }

willUnmount = ->
  @_nativeProps.detach()
