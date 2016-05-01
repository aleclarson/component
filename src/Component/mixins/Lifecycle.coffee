
require "isDev"

{ assert, assertType } = require "type-utils"

emptyFunction = require "emptyFunction"
define = require "define"
guard = require "guard"
sync = require "sync"

methodsByPhase =
  willMount: "componentWillMount"
  didMount: "componentDidMount"
  willReceiveProps: "componentWillReceiveProps"
  willUpdate: "componentWillUpdate"
  didUpdate: "componentDidUpdate"
  willUnmount: "componentWillUnmount"

module.exports = (type) ->

  type.willBuild typePhases.willBuild

  type.initInstance typePhases.initInstance

  type.defineValues typeValues

  type.defineMethods typeMethods

typeValues =

  _render: -> emptyFunction.thatReturnsFalse

  _shouldUpdate: -> emptyFunction.thatReturnsTrue

typeMethods =

  shouldUpdate: (shouldUpdate) ->
    assert not @_shouldUpdate, "'shouldUpdate' is already defined!"
    assertType shouldUpdate, Function
    @_shouldUpdate = shouldUpdate
    return

  render: (render) ->
    assertType render, Function
    @_render = (props) ->
      guard => render.call this, props
      .fail (error) =>
        if isDev
          element = @_reactInternalInstance._currentElement
          stack = element._trace()
        method = @constructor.name + ".render"
        throwFailure error, { context: this, method, stack }
        return no
    return

typePhases =

  willBuild: ->

    # This will hold all methods that are used to add
    # lifecycle-based phases to 'Component.Builder' (eg: didMount)
    lifecycle = {}

    sync.each methodsByPhase, (phaseName, methodName) ->
      lifecycle[methodName] = (fn) ->
        assertType fn, Function
        @_phases[phaseName].push fn
        return

    type.defineMethods lifecycle

  initInstance: ->

    combine @_phases,
      willMount: []
      didMount: []
      willReceiveProps: []
      willUpdate: []
      didUpdate: []
      willUnmount: []

    @willBuild instancePhases.willBuild

instancePhases =

  willBuild: ->

    render = @_render
    shouldUpdate = @_shouldUpdate

    instanceMethods =

      render: ->
        render.call @context, @view.props

      componentShouldUpdate: ->
        shouldUpdate.call @context

    sync.each methodsByPhase, (methodName, phaseName) =>

      callbacks = @_phases[phaseName]

      return if callbacks.length is 0

      if callbacks.length is 1
        callback = callbacks
        method = ->
          callback.call @context
          return

      else
        method = ->
          { context } = this
          for callback in callbacks
            callback.call context
          return

      methods[methodName] = method

    @_viewType.defineMethods methods
