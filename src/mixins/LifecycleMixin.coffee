
{mutable} = require "Property"

ReactComponent = require "ReactComponent"
emptyFunction = require "emptyFunction"
assertType = require "assertType"
applyChain = require "applyChain"
Builder = require "Builder"

module.exports = (type) ->
  type.defineMethods typeImpl.methods
  type.initInstance typeImpl.initInstance

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.methods =

  render: (func) ->
    assertType func, Function
    mutable.define this, "_render", {value: func}
    return

  shouldUpdate: (func) ->
    assertType func, Function
    mutable.define this, "_shouldUpdate", {value: func}
    return

  willReceiveProps: (func) ->
    assertType func, Function
    mutable.define this, "_willReceiveProps", {value: func}
    return

  willMount: (func) ->
    assertType func, Function
    @_phases.willMount.push func
    return

  didMount: (func) ->
    assertType func, Function
    @_phases.didMount.push func
    return

  willUpdate: (func) ->
    assertType func, Function
    @_phases.willUpdate.push func
    return

  didUpdate: (func) ->
    assertType func, Function
    @_phases.didUpdate.push func
    return

  willUnmount: (func) ->
    assertType func, Function
    @_phases.willUnmount.push func
    return

typeImpl.initInstance = ->
  @_phases.willMount = []
  @_phases.didMount = []
  @_phases.willUpdate = []
  @_phases.didUpdate = []
  @_phases.willUnmount = []
  @willBuild instImpl.willBuild

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
    @_render and ownMethods.__render = @_render
    @_shouldUpdate and ownMethods.__shouldUpdate = @_shouldUpdate
    @_willReceiveProps and ownMethods.__willReceiveProps = @_willReceiveProps
    @_delegate.overrideMethods ownMethods
    inheritArrays @_phases,
      willMount: kind::__willMount
      didMount: kind::__didMount
      willUpdate: kind::__willUpdate
      didUpdate: kind::__didUpdate
      willUnmount: kind::__willUnmount

  # Define the arrays on the view to avoid crowding the delegate namespace.
  @definePrototype
    __willMount: @_phases.willMount
    __didMount: @_phases.didMount
    __willUpdate: @_phases.willUpdate
    __didUpdate: @_phases.didUpdate
    __willUnmount: @_phases.willUnmount

instImpl.methods =

  render: ->
    @_delegate.__render()

  shouldComponentUpdate: (nextProps) ->
    @_delegate.__shouldUpdate nextProps

  componentWillReceiveProps: (nextProps) ->
    @_delegate.__willReceiveProps nextProps

  componentWillMount: ->
    applyChain @__willMount, @_delegate

  componentDidMount: ->
    applyChain @__didMount, @_delegate

  componentWillUpdate: ->
    applyChain @__willUpdate, @_delegate

  componentDidUpdate: ->
    applyChain @__didUpdate, @_delegate

  componentWillUnmount: ->
    applyChain @__willUnmount, @_delegate

#
# Helpers
#

inheritArrays = (obj, arrayMap) ->
  for key, array of arrayMap
    if Array.isArray array
      inheritArray obj, key, array
  return

inheritArray = (obj, key, inherited) ->
  assertType inherited, Array
  if obj[key].length
    return if not inherited.length
    obj[key] = inherited.concat obj[key]
  else obj[key] = inherited
  return
