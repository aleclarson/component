
{frozen} = require "Property"

assertType = require "assertType"
Event = require "Event"

module.exports = (type) ->
  type.defineMethods typeImpl.methods

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.methods =

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
