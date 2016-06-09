
assertType = require "assertType"
Property = require "Property"
Random = require "random"
define = require "define"
Event = require "event"

hasListeners = Symbol "Component.hasListeners"

frozen = Property { frozen: yes }

module.exports = (type) ->
  type.defineMethods typeImpl.methods

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.methods =

  defineListeners: (createListeners) ->

    assertType createListeners, Function

    delegate = @_delegate
    kind = delegate._kind

    if not this[hasListeners]
      define this, hasListeners, yes

      # Since lifecyle phases are inherited, make sure
      # we're the first subclass to call 'defineListeners'.
      unless kind and kind::[hasListeners]

        delegate._didBuild.push (type) ->
          define type.prototype, hasListeners, yes

        delegate._initInstance.push ->
          define this, "__listeners", Object.create null

    phaseId = Random.id()

    delegate._initInstance.push (args) ->

      listeners = []

      # Implicitly retain every new listener.
      onListen = Event.didListen (listener) ->
        listener.stop() # Pause each listener until mounted.
        listeners.push listener

      # Create the listeners.
      createListeners.apply this, args

      # Stop listening for new listeners.
      onListen.stop()

      # Store the listeners for the 'willUnmount' phase.
      @__listeners[phaseId] = listeners
      return

    @_willMount.push ->
      for listener in @__listeners[phaseId]
        listener.start()
      return

    @_willUnmount.push ->
      for listener in @__listeners[phaseId]
        listener.defuse()
      return

    return
