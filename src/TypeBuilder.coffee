
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
    "propTypes"
    "propDefaults"
  }

  # Proxy both the getter and setter.
  @definePrototype sync.map keys, (key) ->
    get: -> @_componentType[key]
    set: (newValue) ->
      @_componentType[key] = newValue

  keys = {
    "defineProps"
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

    # Build the underlying component type.
    View = @_componentType.build()
    @defineStatics { View }

    # Define once per inheritance chain.
    unless @_kind instanceof modx_Type
      @defineValues instImpl.defineValues
      @defineGetters instImpl.defineGetters

  defineValues:

    render: ->
      ElementType @constructor.View, (props) =>
        props.delegate = this
        return props

    _props: null

    _view: null

  defineGetters:

    props: -> @_props

    view: -> @_view

# In this context, 'view' is the component instance.
# Thus 'viewImpl' is the component factory.
viewImpl =

  willBuild: ->

    # Define once per inheritance chain.
    unless @_kind instanceof modx_Type
      @defineGetters viewImpl.defineGetters
      @willBuild -> # Try to be the very last phase.
        @_phases.init.unshift viewImpl.initInstance
        @willUnmount viewImpl.willUnmount

  defineGetters:

    _delegate: -> @props.delegate

  initInstance: ->
    @_delegate._view = this

  willUnmount: ->
    @_props = null
    @_view = null
