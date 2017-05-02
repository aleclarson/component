
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

  if @_kind is ReactComponent
    @defineMethods viewImpl
    @_delegate.defineMethods
      __render: @_render or emptyFunction.thatReturnsFalse
      __shouldUpdate: @_shouldUpdate or emptyFunction.thatReturnsTrue
      __willReceiveProps: @_willReceiveProps or emptyFunction

  else
    @_delegate.overrideMethods
      __render: @_render
      __shouldUpdate: @_shouldUpdate
      __willReceiveProps: @_willReceiveProps

  listeners = getListeners @_phases, @_kind.prototype
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

phaseNames = [
  "willMount"
  "didMount"
  "willUpdate"
  "didUpdate"
  "willUnmount"
]

pushAll = Function.apply.bind [].push

getListeners = (phases, inherited) ->
  map = {}

  for phaseName in phaseNames
    continue unless phases.has phaseName
    key = "__" + phaseName

    if inherited[key]
      array = []
      pushAll array, inherited[key]
      pushAll array, phases.get phaseName
      map[key] = array

    else
      map[key] = phases.get phaseName

  return map

runListeners = (instance, phase) ->

  listeners = instance[phase]
  return unless length = listeners?.length

  if length is 1
    listeners[0].call instance._delegate
    return

  index = -1
  while ++index < length
    listeners[index].call instance._delegate
  return
