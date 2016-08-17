
{frozen} = require "Property"

ValueMapper = require "ValueMapper"
assertType = require "assertType"
Reaction = require "reaction"
isType = require "isType"
sync = require "sync"

module.exports = (type) ->
  type.defineMethods typeImpl.methods

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.methods =

  defineReactions: (reactions) ->

    assertType reactions, Object.or Function

    delegate = @_delegate

    # Some phases must only be defined once per inheritance chain.
    if not @__hasReactions
      frozen.define this, "__hasReactions", { value: yes }
      kind = delegate._kind
      unless kind and kind::__hasReactions
        delegate.didBuild baseImpl.didBuild
        delegate.initInstance baseImpl.initInstance
        @_willMount.push baseImpl.startReactions
        @_willUnmount.push baseImpl.stopReactions

    reactions = ValueMapper
      values: reactions
      define: (obj, key, value) ->
        return if value is undefined
        reaction = createReaction obj, key, value
        obj.__reactions[key] = reaction
        frozen.define obj, key, get: -> reaction.value

    delegate._initPhases.push (args) ->
      reactions.define this, args
    return

#
# The 'base' is the first type in the inheritance chain to define reactions.
#

baseImpl = {}

baseImpl.didBuild = (type) ->
  frozen.define type.prototype, "__hasReactions", { value: yes }

baseImpl.initInstance = ->
  frozen.define this, "__reactions",
    value: Object.create null

baseImpl.stopReactions = ->
  for key, reaction of @__reactions
    reaction.stop()
  return

baseImpl.startReactions = ->
  for key, reaction of @__reactions
    reaction.start()
  return

createReaction = (obj, key, value) ->

  keyPath = obj.constructor.name + "." + key

  if isType value, Reaction
    value.keyPath ?= keyPath
    return value

  if isType value, Function
    options = { get: value, keyPath }

  else if isType value, Object
    options = value
    options.keyPath ?= keyPath

  return Reaction.sync options
