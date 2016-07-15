
require "isDev"

assertType = require "assertType"
assert = require "assert"
guard = require "guard"
sync = require "sync"

module.exports = (type) ->

  type.initInstance typePhases.initInstance

  type.defineValues typeValues

  type.defineMethods typeMethods

shimNames =
  willMount: "componentWillMount"
  didMount: "componentDidMount"
  willReceiveProps: "componentWillReceiveProps"
  willUpdate: "componentWillUpdate"
  didUpdate: "componentDidUpdate"
  willUnmount: "componentWillUnmount"

phaseNames = Object.keys shimNames

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
    assert not @_render, "'render' is already defined!"
    if isDev
      @_render = (props) ->
        guard => render.call this, props
        .fail (error) =>
          element = @_reactInternalInstance._currentElement
          stack = element._trace()
          method = @constructor.name + ".render"
          throwFailure error, { context: this, method, stack }
          return no
    else
      @_render = render
    return

sync.each phaseNames, (phaseName) ->
  typeMethods[phaseName] = (fn) ->
    assertType fn, Function
    @_phases[phaseName].push fn
    return

typePhases =

  initInstance: ->

    for phaseName in phaseNames
      @_phases[phaseName] = []

    @willBuild instancePhases.willBuild

instancePhases =

  willBuild: ->

    render = @_render
    shouldUpdate = @_shouldUpdate

    shims =

      render: ->
        render.call @context, @view.props

      componentShouldUpdate: ->
        shouldUpdate.call @context

    sync.each shimNames, (shimName, phaseName) =>

      callbacks = @_phases[phaseName]

      return if callbacks.length is 0

      if callbacks.length is 1
        callback = callbacks
        shim = ->
          callback.call @context
          return

      else
        shim = ->
          { context } = this
          for callback in callbacks
            callback.call context
          return

      shims[shimName] = shim

    @_viewType.defineMethods shims
