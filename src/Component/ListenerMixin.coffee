
assertType = require "assertType"
define = require "define"
Event = require "event"

module.exports = (type) ->
  type.defineMethods typeMethods

typeMethods =

  defineListeners: (createListeners) ->

    assertType createListeners, Function

    if not @_hasListeners
      define this, "_hasListeners", yes
      @_hasListeners = yes

      @_initInstance.push ->
        define this, "__listeners", []

      @willMount ->
        for listener in @__listeners
          listener.start()
        return

      @willUnmount ->
        for listener in @__listeners
          listener.stop()
        return

    @_initInstance.push (args) ->

      # Implicitly retain each created listener.
      onListen = Event.didListen (listener) =>
        listener.stop()
        @__listeners.push listener

      createListeners.apply this, args
      onListen.stop()
