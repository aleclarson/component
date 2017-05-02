
{AnimatedValue} = require "Animated"
{frozen} = require "Property"

emptyFunction = require "emptyFunction"
assertType = require "assertType"
Reaction = require "Reaction"
Random = require "random"
isType = require "isType"
isDev = require "isDev"
bind = require "bind"
sync = require "sync"

Mixin = require "./Mixin"

module.exports = (type) ->
  type.defineMethods {defineReactions}

defineReactions = (reactions) ->

  isDev and
  assertType reactions, Object.or Function

  delegate = @_delegate
  if delegate._needs "reactions"
    delegate.addMixin rootMixin

  if isType reactions, Function
  then delegate.addMixin captureMixin, reactions
  else delegate.addMixin animatedMixin, reactions

# Applied once to each prototype chain.
rootMixin = (type) ->
  type.createValue "__reactions", ->
    return Object.create null

# Captures any `Reaction` instances created within the `createReactions` function.
# The reactions are created during the `didMount` component phase.
# The reactions are stored in `this.__reactions` away from the end user.
captureMixin = (delegate, createReactions) ->
  id = Random.id()

  delegate.didMount ->
    @__reactions[id] = reactions = []
    onInit = (reaction) -> reactions.push reaction.start()
    onInit = Reaction.didInit onInit
    createReactions.apply this, arguments
    onInit.detach()

  delegate.willUnmount ->
    reaction.stop() for reaction in @__reactions[id]
    delete @__reactions[id]
  return

# Creates a `Reaction` for each key in the given map, using the value as the `options` object.
# Each reaction updates its own `AnimatedValue` which is exposed as the corresponding key.
# The reactions are created during the `willMount` component phase.
# The reactions are stored in `this.__reactions` away from the end user.
animatedMixin = (delegate, configs) ->
  id = Random.id()

  delegate._values.push ->
    @__reactions[id] = reactions = []
    for key, config of configs
      reaction = defineReaction this, key, config
      reactions.push reaction
    return

  delegate.willMount ->
    reactions = @__reactions[id]
    reaction.start() for reaction in reactions
    return

  delegate.willUnmount ->
    reactions = @__reactions[id]
    reaction.stop() for reaction in reactions
    return
  return

defineReaction = (obj, key, config) ->
  return unless config?

  isDev and
  assertType config, Function.or Object

  value = AnimatedValue null
  frozen.define obj, key, {value}

  if isType config, Function
    config =
      get: bind.func config, obj
      didSet: (newValue) ->
        if newValue isnt value.get()
          value._updateValue newValue

  else if isType config, Object
    config.didSet = do ->
      didSet = config.didSet or emptyFunction
      return (newValue) ->
        if newValue isnt value.get()
          value._updateValue newValue
          didSet.call obj, newValue

  reaction = Reaction config
  reaction.keyPath ?= obj.constructor.name + "." + key
  return reaction
