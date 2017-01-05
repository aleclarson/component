
{frozen} = require "Property"

NamedFunction = require "NamedFunction"
setKind = require "setKind"
setType = require "setType"
Type = require "Type"
sync = require "sync"

ElementType = require "./utils/ElementType"
Component = require "./Component"

# Creates the constructor for a view model.
modx_Type = NamedFunction "modx_Type", (name) ->

  type = modx_Type.Builder name

  type.didBuild (type) ->
    setType type, modx_Type

  return type

module.exports = setKind modx_Type, Type

modx_Type.Builder = do ->

  type = Type "modx_TypeBuilder"

  type.inherits Type.Builder

  type.trace()

  type.defineValues

    _componentType: ->
      name = if @_name then @_name + "_View" else null
      type = Component name
      frozen.define type, "_delegate", {value: this}
      return type

  type.initInstance ->
    ViewMixin.apply @_componentType
    ViewModelMixin.apply this

  type.overrideMethods

    __didInherit: (kind) ->
      if kind instanceof modx_Type
        @_componentType.inherits kind.render.componentType
      return

    __willBuild: ->
      @defineStatics
        render: @_componentType.build()
      return

  type.willBuild ->

    keys = {
      "inheritProps"
      "definePropDefaults"
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
      "defineAnimatedValues"
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

  return type.build()

ViewModelMixin = do ->

  mixin = Component.Mixin()

  mixin.defineValues

    _props: null

    _view: null

  mixin.defineGetters

    props: -> @_props

    view: -> @_view

  mixin.defineMethods

    render: (props) ->
      @constructor.render props, this

  mixin.willUnmount ->
    @_props = null
    @_view = null

  apply: (type) ->
    # Define once per inheritance chain.
    unless type._kind instanceof modx_Type
      mixin.apply type
    return

ViewMixin = do ->

  mixin = Component.Mixin()

  mixin.defineGetters
    _delegate: -> @props.delegate

  # Try to be the very last phase.
  mixin.willBuild do ->

    # We must connect the view to its delegate,
    # so the delegate can access it while rendering.
    connectToDelegate = ->
      @_delegate._view = this

    # Try to be the very first "init" phase.
    return -> @_phases.init.unshift connectToDelegate

  apply: (type) ->
    # Define once per inheritance chain.
    unless type._delegate._kind instanceof modx_Type
      mixin.apply type
    return
