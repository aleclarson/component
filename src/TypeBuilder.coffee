
{frozen} = require "Property"

mergeDefaults = require "mergeDefaults"
fromArgs = require "fromArgs"
isType = require "isType"
steal = require "steal"
sync = require "sync"
Type = require "Type"

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
    frozen.define type, "_delegate", { value: this }
    return type

type.overrideMethods

  inherits: (kind) ->

    @__super arguments

    if kind instanceof modx_Type
      @_componentType.inherits kind.View
    return

type.willBuild ->

  keys = { "propTypes", "propDefaults" }

  # Proxy both the getter and setter.
  @definePrototype sync.map keys, (key) ->
    get: -> @_componentType[key]
    set: (newValue) ->
      @_componentType[key] = newValue

  keys = { "defineProps", "render", "isRenderPrevented", "shouldUpdate"
    "willReceiveProps", "willMount", "didMount", "willUnmount"
    "defineNativeValues", "defineListeners", "defineReactions"
    "defineStyles", "appendStyles", "overrideStyles" }

  # Proxy a 1-argument function.
  @definePrototype sync.map keys, (key) ->
    value: (func) -> @_componentType[key] func

  keys = { "_willMount", "_didMount", "_willUnmount" }

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
instImpl = {}

instImpl.willBuild = ->

  # Build the underlying component type.
  View = @_componentType.build()
  @defineStatics { View }

  # Define once per inheritance chain.
  unless @_kind instanceof modx_Type
    @defineValues instImpl.values
    @defineGetters instImpl.getters

instImpl.values =

  render: ->
    styles = @_styles
    transform = styles and steal styles, "transform"
    ElementType @constructor.View, (props) =>

      if styles
        if isType props.styles, Object
          mergeDefaults props.styles, styles
          if Array.isArray transform
            if Array.isArray props.styles.transform
              props.styles.transform.concat transform
            else props.style.transform = transform
        else
          mergeDefaults props.styles = {}, styles
          props.styles.transform = transform

      props.delegate = this
      return @_props = props

  _props: null

  _view: null

  _styles: fromArgs "styles"

instImpl.getters =

  props: -> @_props

  view: -> @_view

# In this context, 'view' is the component instance.
# Thus 'viewImpl' is the component factory.
viewImpl = {}

viewImpl.willBuild = ->

  # Define once per inheritance chain.
  unless @_kind instanceof modx_Type
    @willBuild -> # Try to be the very last phase.
      @_initPhases.unshift viewImpl.initInstance
      @_willUnmount.push viewImpl.willUnmount
      @defineGetters viewImpl.getters

viewImpl.getters =

  _delegate: -> @props.delegate

viewImpl.initInstance = ->
  @_delegate._view = this

viewImpl.willUnmount = ->
  @_props = null
  @_view = null
