
require "isDev"

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

# Proxy a higher-order function.
[  ].forEach (key) ->

# Proxy a bound, higher-order function.
[ "render", "shouldUpdate", "defineListeners", "isRenderPrevented" ].forEach (key) ->

  typeImpl.prototype[key] = value: (func) ->
    bound = -> func.apply @_delegate, arguments
    if isDev then bound.toString = -> func.toString()
    @_componentType[key] bound

# Proxy a function that takes an argument.
[ "willMount", "didMount", "willUnmount", "defineStyles",
  "overrideStyles", "defineNativeValues", "defineReactions" ].forEach (key) ->

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

instImpl.prototype =

  props: get: ->
    @_view.props

  view: get: ->
    @_view

instImpl.values =

  render: ->
    ElementType @constructor.View, (props) =>
      props._delegate = this
      return props

  _view: null

instImpl.willBuild = ->
  @defineStatics View: @_componentType.build()
  return if @_kind instanceof Component.Type
  @defineValues instImpl.values
  @definePrototype instImpl.prototype

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
