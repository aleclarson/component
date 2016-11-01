
{frozen} = require "Property"

Type = require "Type"
sync = require "sync"

modx_Type = require "./Type"
Component = require "./Component"
ElementType = require "./utils/ElementType"
ComponentBuilder = require "./ComponentBuilder"

type = Type "modx_TypeBuilder"

type.inherits Type.Builder

type.trace()

type.defineValues

  _componentType: ->
    name = if @_name then @_name + "_View" else null
    type = ComponentBuilder name
    frozen.define type, "_delegate", {value: this}
    return type

type.overrideMethods

  inherits: (kind) ->
    @__super arguments
    if kind instanceof modx_Type
      @_componentType.inherits kind.View
    return

type.willBuild ->

  keys = {
    "defineProps"
    "replaceProps"
    "initProps"
    "render"
    "isRenderPrevented"
    "shouldUpdate"
    "willReceiveProps"
    "willMount"
    "didMount"
    "willUnmount"
    "willUpdate"
    "didUpdate"
    "defineNativeValues"
    "defineListeners"
    "defineReactions"
    "defineStyles"
    "appendStyles"
    "overrideStyles"
  }

  # Proxy a 1-argument function.
  @definePrototype sync.map keys, (key) ->
    value: (arg) -> @_componentType[key] arg

  keys = {
    "_willMount"
    "_didMount"
    "_willUnmount"
    "_willUpdate"
    "_didUpdate"
  }

  # Proxy just the getter.
  @definePrototype sync.map keys, (key) ->
    get: -> @_componentType[key]

type.initInstance ->
  @willBuild instImpl.willBuild
  @_componentType.willBuild viewImpl.willBuild

module.exports = type.build()

#
# Internal
#

# This is defined on each modx_TypeBuilder.
instImpl = {}

instImpl.willBuild = ->

  # Define once per inheritance chain.
  unless @_kind instanceof modx_Type
    @defineValues instImpl.defineValues
    @defineGetters instImpl.defineGetters
    @defineMethods instImpl.defineMethods

  # Build the underlying component type.
  View = @_componentType.build()
  createElement = ElementType View

  @defineStatics {View, createElement}
  return

instImpl.defineValues =

  _props: null

  _view: null

instImpl.defineGetters =

  props: -> @_props

  view: -> @_view

instImpl.defineMethods =

  render: (props) ->
    @constructor.createElement props, this

# In this context, 'view' is the component instance.
# Thus 'viewImpl' is the component factory.
# This is
viewImpl = {}

viewImpl.willBuild = ->

  # Define once per inheritance chain.
  return if @_delegate._kind instanceof modx_Type

  @defineGetters viewImpl.defineGetters

  # Try to be the very last phase.
  @willBuild ->
    @_phases.init.unshift viewImpl.initInstance
    @willUnmount viewImpl.willUnmount
  return

viewImpl.initInstance = ->
  @_delegate._view = this

# NOTE: 'this' context equals 'this._delegate'.
viewImpl.willUnmount = ->
  @_props = null
  @_view = null

viewImpl.defineGetters =

  _delegate: -> @props.delegate
