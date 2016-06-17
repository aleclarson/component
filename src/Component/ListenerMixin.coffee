
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

  defineListeners: (func) ->

    assertType func, Function

    delegate = @_delegate

    # Some phases must only be defined once per inheritance chain.
    if not this[hasListeners]
      frozen.define this, hasListeners, yes
      kind = delegate._kind
      unless kind and kind::[hasListeners]
        delegate._didBuild.push baseImpl.didBuild
        delegate._initInstance.push baseImpl.initInstance

    phaseId = Random.id()

    #
    # Create the Listener objects for each instance.
    #

    createListeners = (args) ->

      listeners = []
      onAttach = Event.didAttach (listener) ->
        listeners.push listener

      onAttach.start()
      func.apply this, args
      onAttach.stop()

      @__listeners[phaseId] = listeners
      return

    delegate._initInstance.push createListeners

    #
    # Start each Listener when the instance is mounted.
    #

    startListeners = ->
      for listener in @__listeners[phaseId]
        listener.start()
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
  frozen.define type.prototype, hasListeners, yes

baseImpl.initInstance = ->
  frozen.define this, "__listeners", Object.create null
