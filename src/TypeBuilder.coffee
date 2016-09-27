
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
    "defineMountedListeners"
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

# In this context, 'inst' is the model instance.
# Thus 'instImpl' is the model factory.
instImpl =

  willBuild: ->

    # Define once per inheritance chain.
    unless @_kind instanceof modx_Type
      @defineValues instImpl.defineValues
      @defineGetters instImpl.defineGetters
      @defineMethods instImpl.defineMethods

    # Build the underlying component type.
    componentType = @_componentType.build()
    @defineStatics
      View: componentType
      _createElement: ElementType componentType
    return

  defineValues:

    _props: null

    _view: null

  defineGetters:

    props: -> @_props

    view: -> @_view

  defineMethods:

    render: (props) ->
      @constructor._createElement props, this

# In this context, 'view' is the component instance.
# Thus 'viewImpl' is the component factory.
viewImpl =

  willBuild: ->

    # Define once per inheritance chain.
    return if @_delegate._kind instanceof modx_Type

    @defineGetters viewImpl.defineGetters

    # Try to be the very last phase.
    @willBuild ->
      @_phases.init.unshift viewImpl.initInstance
      @willUnmount viewImpl.willUnmount
    return

  initInstance: ->
    @_delegate._view = this

  # NOTE: 'this' context equals 'this._delegate'.
  willUnmount: ->
    @_props = null
    @_view = null

  defineGetters:

    _delegate: -> @props.delegate
