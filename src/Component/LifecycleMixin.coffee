
require "isDev"

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

  _render: null

  _shouldUpdate: null

  _willMount: -> []

  _didMount: -> []

  _willUnmount: -> []

typeImpl.methods =

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

  shouldUpdate: (func) ->
    assertType func, Function
    func = bindDelegate func if @_delegate
    @_shouldUpdate = func
    return

  render: (func) ->
    assertType func, Function
    func = bindDelegate func if @_delegate
    @_render = func
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

  if kind is ReactComponent
    @defineMethods viewImpl.methods
    ownMethods.render = @_render or emptyFunction.thatReturnsFalse
    ownMethods.shouldComponentUpdate = @_shouldUpdate or emptyFunction.thatReturnsTrue

  else
    inheritArray this, "_willMount", kind
    inheritArray this, "_didMount", kind
    inheritArray this, "_willUnmount", kind
    ownMethods.render = @_render if @_render
    ownMethods.shouldComponentUpdate = @_shouldUpdate if @_shouldUpdate

  @defineMethods ownMethods
  @definePrototype {
    @_willMount
    @_didMount
    @_willUnmount
  }

#
# The 'view' is a subclass of 'ReactComponent'
#   that was created by 'Component.Builder'
#

viewImpl = {}

viewImpl.methods =

  componentWillMount: ->
    applyChain @_willMount, @_delegate

  componentDidMount: ->
    applyChain @_didMount, @_delegate

  componentWillUnmount: ->
    applyChain @_willUnmount, @_delegate

#
# Helpers
#

bindDelegate = (func) ->
  bound = -> func.apply @_delegate, arguments
  if isDev then bound.toString = -> func.toString()
  return bound

inheritArray = (obj, key, type) ->
  inherited = type.prototype[key]
  assertType inherited, Array
  if obj[key].length
    return if not inherited.length
    obj[key] = inherited.concat obj[key]
  else obj[key] = inherited
  return
