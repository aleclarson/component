
{frozen} = require "Property"

ReactComponent = require "ReactComponent"
emptyFunction = require "emptyFunction"
assertType = require "assertType"
applyChain = require "applyChain"
Builder = require "Builder"

module.exports = (type) ->
  type.defineValues typeImpl.values
  type.defineMethods typeImpl.methods
  type.initInstance typeImpl.initInstance

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.values =

  _willMount: -> []

  _didMount: -> []

  _willUnmount: -> []

typeImpl.methods =

  render: (func) ->
    assertType func, Function
    frozen.define this, "_render", { value: func }
    return

  shouldUpdate: (func) ->
    assertType func, Function
    frozen.define this, "_shouldUpdate", { value: func }
    return

  willReceiveProps: (func) ->
    assertType func, Function
    frozen.define this, "_willReceiveProps", { value: func }
    return

  willMount: (func) ->
    assertType func, Function
    @_willMount.push func
    return

  didMount: (func) ->
    assertType func, Function
    @_didMount.push func
    return

  willUnmount: (func) ->
    assertType func, Function
    @_willUnmount.push func
    return

typeImpl.initInstance = ->
  @_willBuild.push instImpl.willBuild

# In this context, 'inst' is a component factory.
# Thus 'instImpl' defines the behavior of each component instance.
instImpl = {}

instImpl.willBuild = ->

  kind = @_kind
  ownMethods = {}

  if kind is no
    @defineMethods instImpl.methods
    ownMethods.__render = @_render or emptyFunction.thatReturnsFalse
    ownMethods.__shouldUpdate = @_shouldUpdate or emptyFunction.thatReturnsTrue
    ownMethods.__willReceiveProps = @_willReceiveProps or emptyFunction
    @_delegate.defineMethods ownMethods

  else
    inheritArray this, "_willMount", kind::__willMount
    inheritArray this, "_didMount", kind::__didMount
    inheritArray this, "_willUnmount", kind::__willUnmount
    @_render and ownMethods.__render = @_render
    @_shouldUpdate and ownMethods.__shouldUpdate = @_shouldUpdate
    @_willReceiveProps and ownMethods.__willReceiveProps = @_willReceiveProps
    @_delegate.overrideMethods ownMethods

  # Define the arrays on the view to avoid crowding the delegate namespace.
  @definePrototype
    __willMount: @_willMount
    __didMount: @_didMount
    __willUnmount: @_willUnmount

instImpl.methods =

  render: ->
    debugger if not @_delegate.__render
    @_delegate.__render()

  shouldComponentUpdate: (nextProps) ->
    @_delegate.__shouldUpdate nextProps

  componentWillReceiveProps: (nextProps) ->
    @_delegate.__willReceiveProps nextProps

  componentWillMount: ->
    applyChain @__willMount, @_delegate

  componentDidMount: ->
    applyChain @__didMount, @_delegate

  componentWillUnmount: ->
    applyChain @__willUnmount, @_delegate

#
# Helpers
#

inheritArray = (obj, key, inherited) ->
  assertType inherited, Array
  if obj[key].length
    return if not inherited.length
    obj[key] = inherited.concat obj[key]
  else obj[key] = inherited
  return
