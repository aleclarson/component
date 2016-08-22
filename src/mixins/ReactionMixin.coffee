
{frozen} = require "Property"

ValueMapper = require "ValueMapper"
assertType = require "assertType"
Reaction = require "Reaction"
isType = require "isType"
bind = require "bind"
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

    if isType reactions, Object
      reactions = sync.map reactions, (value) ->
        if isType value, Function
          return {get: value}
        return value

    reactions = ValueMapper
      values: reactions
      define: (obj, key, value) ->
        return if value is undefined
        reaction = getReaction obj, key, value
        obj.__reactions[key] = reaction
        frozen.define obj, key, get: -> reaction.value

    # NOTE: 'args' are not used here since Reactions would
    #         only be able to access them on the first run.
    defineReactions = -> reactions.define this
    delegate._initPhases.push defineReactions
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

#
# Helpers
#

getReaction = do ->

  bindClone = (values, context) ->
    clone = {}
    for key, value of values
      clone[key] =
        if isType value, Function
          bind.func value, context
        else value
    return clone

  createOptions = (arg, context) ->

    if isType arg, Object
      return bindClone arg, context

    if isType arg, Function
      return {get: bind.func arg, context}

    throw TypeError "Expected an Object or Function!"

  return getReaction = (obj, key, value) ->

    if isType value, Reaction
      value.keyPath ?= obj.constructor.name + "." + key
      return value

    options = createOptions value, obj
    options.keyPath ?= obj.constructor.name + "." + key
    return Reaction.sync options
