
{ frozen } = require "Property"

assertType = require "assertType"
Random = require "random"
define = require "define"
Event = require "Event"

hasListeners = Symbol "Component.hasListeners"

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

    # Some phases must only be defined once per inheritance chain.
    if not this[hasListeners]
      frozen.define this, hasListeners, { value: yes }
      kind = delegate._kind
      unless kind and kind::[hasListeners]
        delegate._didBuild.push baseImpl.didBuild
        delegate._initInstance.push baseImpl.initInstance

    phaseId = Random.id()

    #
    # Create new Listeners every time the instance is mounted.
    #

    startListeners = ->
      listeners = []
      onAttach = (listener) -> listeners.push listener
      onAttach = Event.didAttach(onAttach).start()
      createListeners.call this
      onAttach.stop()
      listener.start() for listener in listeners
      @__listeners[phaseId] = listeners
      return

    @_willMount.push startListeners

    #
    # Stop each Listener when the instance is unmounted.
    #

    stopListeners = ->
      for listener in @__listeners[phaseId]
        listener.stop()
      return

    @_willUnmount.push stopListeners
    return

#
# The 'base' is the first type in the inheritance chain to define listeners.
#

baseImpl = {}

baseImpl.didBuild = (type) ->
  frozen.define type.prototype, hasListeners, { value: yes }

baseImpl.initInstance = ->
  frozen.define this, "__listeners",
    value: Object.create null
