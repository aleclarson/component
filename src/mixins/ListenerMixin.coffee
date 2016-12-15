
{frozen} = require "Property"

Event = require "Event"

ComponentMixin = require "../ComponentMixin"

module.exports = (type) ->
  type.defineMethods {defineListeners}

defineListeners = (createListeners) ->

  delegate = @_delegate
  unless delegate._hasListeners
    frozen.define delegate, "_hasListeners", {value: yes}
    kind = delegate._kind
    unless kind and kind::_hasListeners
      mixin.apply delegate

  # Create/start listeners in the `willMount` phase.
  delegate.willMount (args) ->
    listeners = @__listeners
    onAttach = (listener) -> listeners.push listener.start()
    onAttach = Event.didAttach(onAttach).start()
    createListeners.apply this, args
    onAttach.detach()

mixin = ComponentMixin()

mixin.defineValues ->
  __listeners: []

mixin.willUnmount ->
  listener.detach() for listener in @__listeners
  @__listeners = []

mixin.didBuild (type) ->
  frozen.define type::, "_hasListeners", {value: yes}
