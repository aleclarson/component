
{ throwFailure } = require "failure"

ReactElement = require "ReactElement"
assertTypes = require "assertTypes"
assertType = require "assertType"

ElementType = require "../Component/ElementType"
NativeProps = require "./Props"
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
    type.propTypes = config.propTypes

  type.definePrototype
    renderChild: ElementType config.render

  type.defineValues typeImpl.values
  type.defineListeners typeImpl.listeners
  type.willUnmount typeImpl.willUnmount
  type.render typeImpl.render

  return type.build()

typeImpl = {}

typeImpl.values =

  child: null

  _queuedProps: null

  _nativeProps: ->
    NativeProps @props, @constructor.propTypes

typeImpl.render = ->
  props = @_nativeProps.values
  props.ref = setChild.bind this
  @renderChild props

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

setChild = (view) ->
  @child = view
  if view and @_queuedProps
    @child.setNativeProps @_queuedProps
    @_queuedProps = null
  return
