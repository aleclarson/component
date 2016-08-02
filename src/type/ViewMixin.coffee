
Property = require "Property"

ComponentBuilder = require "../ComponentBuilder"
ElementType = require "./ElementType"

{ mutable, frozen } = Property

module.exports = (type) ->
  type.defineValues typeImpl.values
  type.definePrototype typeImpl.prototype
  type.initInstance typeImpl.initInstance

#
# The 'type' is the 'Component.Type.Builder' constructor
#

typeImpl = {}

typeImpl.values =

  _componentType: ->
    name = if @_name then @_name + "_View" else null
    self = ComponentBuilder name
    frozen.define self, "_delegate", { value: this }
    return self

typeImpl.prototype = {}

# Proxy both the getter and setter.
[ "propTypes"
  "propDefaults"
].forEach (key) ->
  typeImpl.prototype[key] =
    get: -> @_componentType[key]
    set: (newValue) ->
      @_componentType[key] = newValue

# Proxy a 1-argument function.
[ "render"
  "isRenderPrevented"
  "shouldUpdate"
  "willReceiveProps"
  "willMount"
  "didMount"
  "willUnmount"
  "defineNativeValues"
  "defineListeners"
  "defineReactions"
  "defineStyles"
  "appendStyles"
  "overrideStyles"
].forEach (key) ->
  typeImpl.prototype[key] = value: (func) ->
    @_componentType[key] func

# Proxy just the getter.
[ "_willMount"
  "_didMount"
  "_willUnmount"
].forEach (key) ->
  typeImpl.prototype[key] = get: ->
    @_componentType[key]

typeImpl.initInstance = ->
  @_willBuild.push instImpl.willBuild
  @_componentType.willBuild viewImpl.willBuild

#
# The 'instance' is a 'Component.Type.Builder' that is not yet built.
#

$ =
  delegate: Symbol "Component.delegate"
  styles: Symbol "Component.styles"
  props: Symbol "Component.props"
  view: Symbol "Component.view"

instImpl = {}

instImpl.willBuild = ->

  # Build the underlying component type.
  @defineStatics View: @_componentType.build()

  # Only define this stuff once per inheritance chain.
  unless @_kind instanceof Component.Type
    @definePrototype instImpl.prototype
    @defineValues instImpl.values
    @initInstance instImpl.initInstance

instImpl.prototype =

  props: get: ->
    this[$.props]

  view: get: ->
    this[$.view]

instImpl.values =

  render: ->
    return ElementType @constructor.View, (props) =>
      props[$.delegate] = this
      mergeStyles props, this[$.styles]
      return this[$.props] = props

instImpl.initInstance = (options = {}) ->
  mutable.define this, $.props, { value: null }
  mutable.define this, $.view, { value: null }
  mutable.define this, $.styles, { value: options.styles or null }

mergeStyles = (props, styles) ->

  return if not styles

  if props.styles
    combine props.styles, styles
    return

  props.styles = styles
  return

#
# The 'view' is a 'Type.Builder' that inherits from 'ReactComponent'
#

viewImpl = {}

viewImpl.prototype =

  _delegate: get: ->
    @props[$.delegate]

viewImpl.willBuild = ->
  return if @_kind instanceof Component.Type
  @definePrototype viewImpl.prototype
  @_willBuild.push -> # Try to be the very last phase.
    @_initInstance.unshift viewImpl.initInstance
    @_willUnmount.push viewImpl.willUnmount

viewImpl.initInstance = ->
  @_delegate[$.view] = this

viewImpl.willUnmount = ->
  delegate = @_delegate
  delegate[$.props] = null
  delegate[$.view] = null
