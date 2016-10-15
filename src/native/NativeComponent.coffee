
emptyFunction = require "emptyFunction"
assertTypes = require "assertTypes"
assertType = require "assertType"
sync = require "sync"
hook = require "hook"

PropValidator = require "../utils/PropValidator"
ElementType = require "../utils/ElementType"
NativeProps = require "./NativeProps"
Component = require "../Component"

configTypes =
  render: Function
  propTypes: Object.Maybe
  methods: Array.Maybe
  statics: Array.Maybe

NativeComponent = (name, config) ->

  assertType name, String
  assertTypes config, configTypes
  {render, propTypes} = config

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

  if config.methods
    type.defineMethods do ->
      sync.reduce config.methods, {}, (methods, key) ->
        methods[key] = -> @_child[key].apply @_child, arguments
        return methods

  if config.statics
    type.defineStatics do ->
      sync.reduce config.statics, {}, (statics, key) ->
        statics[key] = get: -> render[key]
        return statics

  typeMixin.apply type
  return type.build()

module.exports = NativeComponent

# This is applied to every NativeComponent type
typeMixin = Component.Mixin()

typeMixin.defineValues

  _child: null

  _queuedProps: null

  _nativeProps: ->
    props = NativeProps @constructor.propTypes
    return props.attach @props

typeMixin.defineBoundMethods

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

typeMixin.defineMountedListeners ->
  @_nativeProps.didSet @setNativeProps

#
# Rendering
#

typeMixin.render ->
  props = @_nativeProps.values
  hook props, "ref", @_hookRef
  return @_renderChild props

typeMixin.willUnmount ->
  @_nativeProps.detach()
  return

typeMixin.willReceiveProps (nextProps) ->
  @_nativeProps.attach nextProps
  return
