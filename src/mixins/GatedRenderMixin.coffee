
{mutable} = require "Property"

assertType = require "assertType"
Reaction = require "Reaction"

ComponentMixin = require "../ComponentMixin"

module.exports = (type) ->
  type.defineMethods {isRenderPrevented}

isRenderPrevented = (func) ->

  assertType func, Function

  if @_isRenderPrevented
    throw Error "'isRenderPrevented' is already defined!"
  mutable.define this, "_isRenderPrevented", {value: func}

  delegate = @_delegate
  delegate.defineMethods {isRenderPrevented: func}
  mixin.apply delegate
  return

mixin = ComponentMixin()

mixin.defineValues ->

  __needsRender: no

mixin.defineReactions

  __shouldRender: ->
    @isRenderPrevented() is no

mixin.defineListeners ->
  @__shouldRender.didSet (shouldRender) =>
    if shouldRender and @__needsRender
      @__needsRender = no
      @view.forceUpdate()
    return

mixin.willBuild ->
  @didBuild (type) ->
    hook type.prototype,
      __render: gatedRender
      __shouldUpdate: gatedRender

#
# Helpers
#

hook = (obj, methods) ->
  for key, method of methods
    mutable.define obj, key,
      value: createHook method, obj[key]
  return

createHook = (method, orig) ->
  return -> method.call this, orig, arguments

# Must be used with `hook()`
gatedRender = (orig, args) ->

  # Allow the render to go through
  if @__shouldRender.get()
    return orig.apply this, args

  # Wait for `isRenderPrevented`
  @__needsRender = yes
  return null
