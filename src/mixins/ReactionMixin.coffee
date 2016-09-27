
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

    if isType reactions, Object
      reactions = sync.map reactions, (value) ->
        if isType value, Function
          return -> value
        return value

    reactions = ValueMapper
      values: reactions
      define: (obj, key, value) ->
        return if value is undefined
        reaction = getReaction obj, key, value
        frozen.define obj, key, {value: reaction}
        reaction.start()

    # NOTE: 'args' are not used here since Reactions would
    #         only be able to access them on the first run.
    defineReactions = -> reactions.define this
    delegate._phases.init.push defineReactions
    return

#
# The 'base' is the first type in the inheritance chain to define reactions.
#

baseImpl =

  didBuild: (type) ->
    frozen.define type.prototype, "__hasReactions", { value: yes }

  initInstance: ->
    frozen.define this, "__reactions",
      value: Object.create null

#
# Helpers
#

getReaction = (obj, key, value) ->

  if isType value, Reaction
    value.keyPath ?= obj.constructor.name + "." + key
    return value

  options =
    if isType value, Function
    then get: bind.func value, obj
    else value

  options.keyPath ?= obj.constructor.name + "." + key
  return Reaction options
