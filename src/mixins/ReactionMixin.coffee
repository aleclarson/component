
{AnimatedValue} = require "Animated"
{ListenerMixin} = require "Event"
{frozen} = require "Property"

emptyFunction = require "emptyFunction"
ValueMapper = require "ValueMapper"
assertType = require "assertType"
Reaction = require "Reaction"
isType = require "isType"
isDev = require "isDev"
bind = require "bind"

ComponentMixin = require "../ComponentMixin"

module.exports = (type) ->
  type.defineMethods {defineReactions}

defineReactions = (reactions) ->

  isDev and
  assertType reactions, Object.or Function

  # Treat object methods as reaction getters.
  if isType reactions, Object
    for key, reaction of reactions
      if isType reaction, Function
        reactions[key] = emptyFunction.thatReturns reaction

  delegate = @_delegate
  unless delegate._hasReactions
    frozen.define delegate, "_hasReactions", {value: yes}
    kind = delegate._kind
    unless kind and kind::_hasReactions
      mixin.apply delegate

  mapValues = ValueMapper reactions, defineReaction
  delegate._phases.init.push (args) ->
    mapValues this, args
  return

defineReaction = (obj, key, reaction) ->
  return if reaction is undefined

  isDev and
  assertType reaction, Reaction.or Function, Object

  value = AnimatedValue null

  if isType reaction, Function
    reaction = Reaction
      get: bind.func reaction, obj
      didSet: value._updateValue

  else if isType reaction, Object
    onUpdate = reaction.didSet or emptyFunction
    reaction = Reaction
      get: bind.func reaction.get, obj
      didSet: (newValue) ->
        return if newValue is value.get()
        value._updateValue newValue
        onUpdate.call obj, newValue

  reaction.keyPath ?= obj.constructor.name + "." + key
  frozen.define obj, key, {value}
  obj.__reactions.push reaction

mixin = ComponentMixin()

mixin.defineFrozenValues ->
  __reactions: []

mixin.willMount ->
  reactions = @__reactions
  for reaction in reactions
    reaction.start()
  return

mixin.willUnmount ->
  reactions = @__reactions
  for reaction in reactions
    reaction.stop()
  return

mixin.didBuild (type) ->
  frozen.define type::, "_hasReactions", {value: yes}
