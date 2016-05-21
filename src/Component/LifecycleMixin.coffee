
require "isDev"

emptyFunction = require "emptyFunction"
assertType = require "assertType"
applyChain = require "applyChain"
Builder = require "Builder"
assert = require "assert"
guard = require "guard"
sync = require "sync"

module.exports = (type) ->
  type.defineValues typeValues
  type.defineMethods typeMethods
  type.initInstance typePhases.initInstance

typeValues =

  _render: -> emptyFunction.thatReturnsFalse

  _shouldUpdate: -> emptyFunction.thatReturnsTrue

  _willMount: -> []

  _didMount: -> []

  _willUnmount: -> []

typeMethods =

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
    @_shouldUpdate = func
    return

  render: (func) ->
    assertType func, Function
    @_render = func
    return

typePhases =

  initInstance: ->
    @_willBuild.push instancePhases.willBuild

instancePhases =

  willBuild: ->
    @definePrototype { @_willMount, @_didMount, @_willUnmount }
    @defineMethods instanceMethods
    @defineMethods
      shouldComponentUpdate: @_shouldUpdate
      render: @_render

instanceMethods =

  componentWillMount: ->
    applyChain @_willMount, this

  componentDidMount: ->
    applyChain @_didMount, this

  componentWillUnmount: ->
    applyChain @_willUnmount, this
