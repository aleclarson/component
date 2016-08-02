
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

    # Some phases must only be defined once per inheritance chain.
    if not this[hasReactions]
      frozen.define this, hasReactions, { value: yes }
      kind = delegate._kind
      unless kind and kind::[hasReactions]
        delegate._didBuild.push baseImpl.didBuild
        delegate._initInstance.push baseImpl.initInstance

    phaseId = Random.id()

    #
    # Create the Reaction objects for each instance.
    #

    createReactions = (args) ->
      keys = []
      for key, value of reactions
        assertType value, Function, key
        options = value.apply this, args
        continue if options is undefined
        keys.push key
        value =
          if isType options, Reaction then options
          else Reaction.sync options

        frozen.define this, key, { value }

      @__reactionKeys[phaseId] = keys
      return

    delegate._initInstance.push createReactions

    #
    # Start each Reaction right before the instance is mounted.
    #

    startReactions = ->
      for key in @__reactionKeys[phaseId]
        this[key].start()
      return

    @_willMount.push startReactions

    #
    # Stop each Reaction right after the instance unmounts.
    #

    stopReactions = ->
      for key in @__reactionKeys[phaseId]
        this[key].stop()
      return

    @_willUnmount.push stopReactions
    return

#
# The 'base' is the first type in the inheritance chain to define reactions.
#

baseImpl = {}

baseImpl.didBuild = (type) ->
  frozen.define type.prototype, hasReactions, { value: yes }

baseImpl.initInstance = ->
  frozen.define this, "__reactionKeys",
    value: Object.create null
