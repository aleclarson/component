
{frozen} = require "Property"

ValueMapper = require "ValueMapper"
assertType = require "assertType"
Reaction = require "Reaction"
Builder = require "Builder"
isType = require "isType"
bind = require "bind"
sync = require "sync"

# This is applied to the Component.Builder constructor
typeMixin = Builder.Mixin()

typeMixin.defineMethods

  defineReactions: (reactions) ->

    assertType reactions, Object.or Function

    delegate = @_delegate

    # Some phases must only be defined once per inheritance chain.
    if not @__hasReactions
      frozen.define this, "__hasReactions", { value: yes }
      kind = delegate._kind
      unless kind and kind::__hasReactions
        delegate.addMixins [baseMixin.apply]

    if isType reactions, Object
      reactions = sync.map reactions, (value) ->
        if isType value, Function
          return -> value
        return value

    reactions = ValueMapper
      values: reactions
      define: (obj, key, value) ->
        return if value is undefined
        reaction = createReaction obj, key, value
        frozen.define obj, key, {value: reaction}
        reaction.start()

    # NOTE: 'args' are not used here since Reactions would
    #         only be able to access them on the first run.
    defineReactions = -> reactions.define this
    delegate._phases.init.push defineReactions
    return

module.exports = typeMixin.apply

# This is applied to the first type (in its inheritance chain) to call `defineReactions`
baseMixin = Builder.Mixin()

baseMixin.didBuild (type) ->
  frozen.define type.prototype, "__hasReactions", { value: yes }

baseMixin.initInstance ->
  frozen.define this, "__reactions",
    value: Object.create null

#
# Helpers
#

createReaction = (obj, key, value) ->

  if isType value, Reaction
    value.keyPath ?= obj.constructor.name + "." + key
    return value

  options =
    if isType value, Function
    then get: bind.func value, obj
    else value

  options.keyPath ?= obj.constructor.name + "." + key
  return Reaction options
