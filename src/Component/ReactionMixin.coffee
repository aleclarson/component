
assertType = require "assertType"
Property = require "Property"
Reaction = require "reaction"
Random = require "random"
isType = require "isType"
assert = require "assert"
define = require "define"

hasReactions = Symbol "Component.hasReactions"

frozen = Property { frozen: yes }

module.exports = (type) ->
  type.defineMethods typeImpl.methods

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.methods =

  defineReactions: (reactions) ->

    assertType reactions, Object

    delegate = @_delegate
    kind = delegate._kind

    if not this[hasReactions]
      frozen.define this, hasReactions, yes

      # Since lifecyle phases are inherited, make sure
      # we're the first subclass to call 'defineReactions'.
      unless kind and kind::[hasReactions]

        @_didBuild (type) ->
          frozen.define type.prototype, hasReactions, yes

        delegate._initInstance.push ->
          frozen.define this, "__reactionKeys", Object.create null

    phaseId = Random.id()

    delegate._initInstance.push (args) ->

      keys = []

      for key, value of reactions

        assertType value, Function, key

        options = value.apply this, args

        continue if options is undefined

        keys.push key

        value =
          if isType options, Reaction then options
          else Reaction.sync options

        frozen.define this, key, value

      @__reactionKeys[phaseId] = keys
      return

    @_willMount.push ->
      delegate = @_delegate
      for key in delegate.__reactionKeys[phaseId]
        reaction = delegate[key]
        guard -> reaction.start()
        .fail (error) ->
          throwFailure error, { key, reaction, phaseId, delegate }
      return

    @_willUnmount.push ->
      delegate = @_delegate
      for key, reaction of delegate.__reactionKeys[phaseId]
        delegate[key].stop()
      return

    return
