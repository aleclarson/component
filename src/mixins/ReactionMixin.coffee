
Reaction = require "Reaction"

# This is applied to the Component.Builder constructor
module.exports = (type) ->
  type.defineMethods {defineReactions}

defineReactions = (reactions) ->
  delegate = @_delegate
  delegate.addMixin Reaction.Mixin, reactions
  delegate.didMount startReactions
  delegate.willUnmount stopReactions

startReactions = ->
  @startReactions()

stopReactions = ->
  @stopReactions()
