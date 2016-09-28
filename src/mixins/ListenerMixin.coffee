
{frozen} = require "Property"

assertType = require "assertType"
Builder = require "Builder"
Event = require "Event"

# This is applied to the Component.Builder constructor
typeMixin = Builder.Mixin()

typeMixin.defineMethods

  defineMountedListeners: (createListeners) ->

    assertType createListeners, Function

    delegate = @_delegate

    # Some phases must only be defined once per inheritance chain.
    if not @__hasMountedListeners
      frozen.define this, "__hasMountedListeners", {value: yes}
      kind = delegate._kind
      unless kind and kind::__hasMountedListeners
        delegate.didBuild hasMountedListeners
        @willMount startListeners
        @willUnmount stopListeners

    #
    # Create new Listeners every time the instance is mounted.
    #

    delegate.initInstance ->
      listeners = @__mountedListeners or []
      onAttach = Event
        .didAttach (listener) -> listeners.push listener
        .start()

      createListeners.call this
      onAttach.detach()

      for listener in listeners
        listener.start()

      @__mountedListeners or
      frozen.define this, "__mountedListeners", {value: listeners}
      return
    return

module.exports = typeMixin.apply

hasMountedListeners = (type) ->
  frozen.define type.prototype, "__hasMountedListeners", {value: yes}

startListeners = ->
  for listener in @__mountedListeners
    listener.start()
  return

stopListeners = ->
  for listener in @__mountedListeners
    listener.stop()
  return
