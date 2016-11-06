
{frozen} = require "Property"

Event = require "Event"

ComponentMixin = require "../ComponentMixin"

module.exports = (type) ->
  type.defineMethods {defineListeners}

defineListeners = (createListeners) ->

  delegate = @_delegate
  delegate.willMount (args) ->

    listeners = @__listeners
    onAttach = Event.didAttach (listener) ->
      listeners.push listener

    onAttach.start()
    createListeners.apply this, args
    onAttach.detach()

  unless delegate._hasListeners
    frozen.define delegate, "_hasListeners", {value: yes}
    kind = delegate._kind
    unless kind and kind::_hasListeners
      mixin.apply delegate

mixin = ComponentMixin()

mixin.defineValues ->
  __listeners: []

mixin.willMount ->
  for listener in @__listeners
    listener.start()
  return

mixin.willUnmount ->
  for listener in @__listeners
    listener.stop()
  return

mixin.didBuild (type) ->
  frozen.define type::, "_hasListeners", {value: yes}
