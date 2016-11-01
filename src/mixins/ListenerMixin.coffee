
{ListenerMixin} = require "Event"

# This is applied to the Component.Builder constructor
module.exports = (type) ->
  type.defineMethods {defineListeners}

defineListeners = (createListeners) ->
  delegate = @_delegate
  delegate.addMixin ListenerMixin, createListeners
  delegate.didMount startListeners
  delegate.willUnmount stopListeners

startListeners = ->
  @startListeners()

stopListeners = ->
  @stopListeners()
