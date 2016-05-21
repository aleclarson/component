
assertType = require "assertType"
sync = require "sync"

Component = require ".."

module.exports = (type) ->
  type.defineValues typeImpl.values
  type.definePrototype typeImpl.prototype
  type.defineMethods typeImpl.methods
  type.initInstance typeImpl.initInstance

#
# The 'type' is a subclass of 'Type'
#

typeImpl = {}

typeImpl.values =

  _viewType: -> Component()

typeImpl.prototype =

  propTypes:
    get: -> @_viewType.propTypes
    set: (propTypes) ->
      @_viewType.propTypes = propTypes

  propDefaults:
    get: -> @_viewType.propDefaults
    set: (propDefaults) ->
      @_viewType.propDefaults = propDefaults

typeImpl.methods = {}

[ "willMount", "didMount", "willUnmount"
  "shouldUpdate", "render", "isRenderPrevented" ]
.forEach (key) ->
  typeImpl.methods[key] = (func) ->
    @_viewType[key] ->
      func.apply @_instance, arguments
    return

typeImpl.initInstance = ->

  @_willBuild.push instImpl.willBuild

  type = @_viewType
  type.definePrototype viewImpl.prototype
  type.initInstance viewImpl.initInstance
  type.willBuild viewImpl.willBuild

#
# The 'instance' is a subclass of 'Type.Builder'
#

instImpl = {}

instImpl.values =

  _view: null

instImpl.prototype =

  view: get: ->
    @_view

  props: get: ->
    @_view.props

  render: (props) ->
    props = {} if not props
    props._instance = this
    return @constructor.View props

instImpl.willBuild = ->
  @defineStatics View: @_viewType.build()
  return if @_kind
  @defineValues instImpl.values
  @definePrototype instImpl.prototype

#
# The 'view' is a subclass of 'ReactComponent'
#

viewImpl = {}

viewImpl.prototype =

  _instance: get: ->
    @props._instance

viewImpl.initInstance = ->
  @_instance._view = this

viewImpl.willBuild = ->
  @_willUnmount.push ->
    @_instance._view = null
