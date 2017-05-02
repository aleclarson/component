
{frozen} = require "Property"

Event = require "eve"

Mixin = require "./Mixin"

module.exports = (type) ->
  type.defineMethods {defineListeners}

defineListeners = (createListeners) ->

  delegate = @_delegate
  if delegate._needs "listeners"
    delegate.addMixin rootMixin

  # Create/start listeners in the `willMount` phase.
  delegate.willMount ->

    listeners = @__listeners
    onAttach = Event.didAttach (listener) ->
      listeners.push listener

    createListeners.call this
    onAttach.detach()
  return

rootMixin = do ->

  mixin = Mixin()

  mixin.defineValues ->
    __listeners: []

  mixin.willUnmount ->
    listener.detach() for listener in @__listeners
    @__listeners = []
    return

  return mixin.apply
