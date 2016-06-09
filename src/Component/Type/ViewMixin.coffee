
Property = require "Property"

ComponentBuilder = require "../Builder"
ElementType = require "../ElementType"

frozen = Property { frozen: yes }

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
    frozen.define self, "_delegate", this
    return self

typeImpl.prototype = {}

# Proxy both the getter and setter.
[ "propTypes", "propDefaults" ].forEach (key) ->

  typeImpl.prototype[key] =
    get: -> @_componentType[key]
    set: (newValue) ->
      @_componentType[key] = newValue

# Proxy a 1-argument function.
[ "render", "shouldUpdate", "isRenderPrevented", "willMount", "didMount", "willUnmount", "defineStyles", "overrideStyles",
  "defineNativeValues", "defineListeners", "defineReactions" ].forEach (key) ->

  typeImpl.prototype[key] = value: (func) ->
    @_componentType[key] func

# Proxy just the getter.
[ "_willMount", "_didMount", "_willUnmount" ].forEach (key) ->

  typeImpl.prototype[key] = get: ->
    @_componentType[key]

typeImpl.initInstance = ->
  @_willBuild.push instImpl.willBuild
  @_componentType.willBuild viewImpl.willBuild

#
# The 'instance' is a 'Component.Type.Builder' that is not yet built.
#

instImpl = {}

instImpl.willBuild = ->
  @defineStatics View: @_componentType.build()
  return if @_kind instanceof Component.Type
  @defineValues instImpl.values
  @defineMethods instImpl.methods
  @definePrototype instImpl.prototype

instImpl.prototype =

  props: get: ->
    @_props

  view: get: ->
    @_view

instImpl.values =

  render: ->
    ElementType @constructor.View, (props) =>
      props._delegate = this
      @_mixinStyles props if @_styles
      return @_props = props

  _styles: (options) ->
    options and options.styles

  _props: null

  _view: null

instImpl.methods =

  _mixinStyles: (props) ->
    if props.styles
      combine props.styles, @_styles
    else
      props.styles = @_styles
    return

#
# The 'view' is a 'Type.Builder' that inherits from 'ReactComponent'
#

viewImpl = {}

viewImpl.prototype =

  _delegate: get: ->
    @props._delegate

viewImpl.willBuild = ->
  return if @_kind instanceof Component.Type
  @definePrototype viewImpl.prototype
  @_willBuild.push -> # Try to be the very last phase.
    @_initInstance.unshift viewImpl.initInstance
    @_willUnmount.push viewImpl.willUnmount

viewImpl.initInstance = ->
  @_delegate._view = this

viewImpl.willUnmount = ->
  @_delegate._view = null
