
{mutable} = require "Property"

ReactComponent = require "react/lib/ReactComponent"

emptyFunction = require "emptyFunction"
assertType = require "assertType"
Builder = require "Builder"

# This is applied to the Component.Builder constructor
mixin = Builder.Mixin()

mixin.defineMethods

  render: (callback) ->
    assertType callback, Function
    mutable.define this, "_render", {value: callback}
    return

  shouldUpdate: (callback) ->
    assertType callback, Function
    mutable.define this, "_shouldUpdate", {value: callback}
    return

  willReceiveProps: (callback) ->
    assertType callback, Function
    mutable.define this, "_willReceiveProps", {value: callback}
    return

  willMount: (callback) ->
    assertType callback, Function
    @_phases.push "willMount", callback
    return

  didMount: (callback) ->
    assertType callback, Function
    @_phases.push "didMount", callback
    return

  willUpdate: (callback) ->
    assertType callback, Function
    @_phases.push "willUpdate", callback
    return

  didUpdate: (callback) ->
    assertType callback, Function
    @_phases.push "didUpdate", callback
    return

  willUnmount: (callback) ->
    assertType callback, Function
    @_phases.push "willUnmount", callback
    return

mixin.initInstance ->
  @addMixin instMixin.apply

module.exports = mixin.apply

# This is applied to every Component.Builder
instMixin = Builder.Mixin()

instMixin.willBuild ->

  kind = @_kind
  phases = @_phases
  ownMethods = {}

  if kind is ReactComponent
    @defineMethods viewImpl
    ownMethods.__render = @_render or emptyFunction.thatReturnsFalse
    ownMethods.__shouldUpdate = @_shouldUpdate or emptyFunction.thatReturnsTrue
    ownMethods.__willReceiveProps = @_willReceiveProps or emptyFunction
    @_delegate.defineMethods ownMethods

  else
    @_render and ownMethods.__render = @_render
    @_shouldUpdate and ownMethods.__shouldUpdate = @_shouldUpdate
    @_willReceiveProps and ownMethods.__willReceiveProps = @_willReceiveProps
    @_delegate.overrideMethods ownMethods
    inheritListeners kind, phases

  listeners = {}
  for phase, listenerName of listenersByPhase
    if phases.has phase
      listeners[listenerName] = phases.get phase

  @definePrototype listeners
  return

# This interface is shared by every component instance
viewImpl =

  render: ->
    @_delegate.__render()

  shouldComponentUpdate: (nextProps) ->
    @_delegate.__shouldUpdate nextProps

  componentWillReceiveProps: (nextProps) ->
    @_delegate.__willReceiveProps nextProps

  componentWillMount: ->
    runListeners this, "__willMount"

  componentDidMount: ->
    runListeners this, "__didMount"

  componentWillUpdate: ->
    runListeners this, "__willUpdate"

  componentDidUpdate: ->
    runListeners this, "__didUpdate"

  componentWillUnmount: ->
    runListeners this, "__willUnmount"

#
# Helpers
#

listenersByPhase =
  willMount: "__willMount"
  didMount: "__didMount"
  willUpdate: "__willUpdate"
  didUpdate: "__didUpdate"
  willUnmount: "__willUnmount"

inheritListeners = (kind, phases) ->
  {prototype} = kind
  for phase, listenerName of listenersByPhase
    continue unless listeners = prototype[listenerName]
    phases.push phase, listener for listener in listeners
  return

runListeners = (instance, phase) ->
  if listeners = instance[phase]
    delegate = instance._delegate
    for listener in listeners
      listener.call delegate
  return
