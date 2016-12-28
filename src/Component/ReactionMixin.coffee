
{AnimatedValue} = require "Animated"
{ListenerMixin} = require "Event"
{frozen} = require "Property"

emptyFunction = require "emptyFunction"
ValueMapper = require "ValueMapper"
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

mixin = Mixin()

mixin.defineValues ->
  __reactions: Object.create null

mixin.didBuild (type) ->
  frozen.define type::, "_hasReactions", {value: yes}

defineReactions = (reactions) ->

  isDev and
  assertType reactions, Object.or Function

  delegate = @_delegate
  unless delegate._hasReactions
    frozen.define delegate, "_hasReactions", {value: yes}
    kind = delegate._kind
    unless kind and kind::_hasReactions
      mixin.apply delegate

  id = Random.id()
  delegate.willUnmount ->
    reaction.stop() for reaction in @__reactions[id]
    delete @__reactions[id]

  if isType reactions, Function
    createReactions = reactions
    delegate.didMount ->
      @__reactions[id] = cache = []
      onInit = (reaction) -> cache.push reaction.start()
      onInit = Reaction.didInit(onInit).start()
      createReactions.apply this, arguments
      onInit.detach()
    return

  # Use functions in `reactions` as `options.get`
  # passed to the `Reaction` constructor.
  sync.each reactions, (reaction, key) ->
    if isType reaction, Function
      reactions[key] = emptyFunction.thatReturns reaction

  mapValues = ValueMapper reactions, (obj, key, getter) ->

    return if getter is undefined

    isDev and
    assertType getter, Reaction.or Function, Object

    value = AnimatedValue null
    frozen.define obj, key, {value}

    if isType getter, Function
      options =
        get: bind.func getter, obj
        didSet: (newValue) ->
          if newValue isnt value.get()
            value._updateValue newValue

    else if isType getter, Object
      options = getter
      options.didSet = do ->
        didSet = options.didSet or emptyFunction
        return (newValue) ->
          if newValue isnt value.get()
            value._updateValue newValue
            didSet.call obj, newValue

    reaction =
      if options
      then Reaction options
      else getter

    reaction.keyPath ?= obj.constructor.name + "." + key
    obj.__reactions[id].push reaction

  delegate._phases.init.push (args) ->
    @__reactions[id] = []
    mapValues this, args

  delegate.willMount ->
    for reaction in @__reactions[id]
      reaction.start()
    return
