
require "isDev"

{ frozen } = require "Property"

ReactComponent = require "ReactComponent"
emptyFunction = require "emptyFunction"
assertType = require "assertType"
applyChain = require "applyChain"
Builder = require "Builder"
assert = require "assert"
sync = require "sync"

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

#
# The 'instance' is a Component.Builder
#

instImpl = {}

instImpl.willBuild = ->

  kind = @_kind
  ownMethods = {}

  if (kind is no) or (kind is ReactComponent)
    @defineMethods viewImpl.methods
    ownMethods.__render = @_render or emptyFunction.thatReturnsFalse
    ownMethods.__shouldUpdate = @_shouldUpdate or emptyFunction.thatReturnsTrue
    ownMethods.__willReceiveProps = @_willReceiveProps or emptyFunction
    @_delegate.defineMethods ownMethods

  else
    inheritArray this, "_willMount", kind::__willMount
    inheritArray this, "_didMount", kind::__didMount
    inheritArray this, "_willUnmount", kind::__willUnmount
    ownMethods.__render = @_render if @_render
    ownMethods.__shouldUpdate = @_shouldUpdate if @_shouldUpdate
    ownMethods.__willReceiveProps = @_willReceiveProps if @_willReceiveProps
    @_delegate.overrideMethods ownMethods

  # Define the arrays on the view to avoid crowding the delegate namespace.
  @definePrototype
    __willMount: @_willMount
    __didMount: @_didMount
    __willUnmount: @_willUnmount

#
# The 'view' is a subclass of 'ReactComponent'
#   that was created by 'Component.Builder'
#

viewImpl = {}

viewImpl.methods =

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
