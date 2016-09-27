
{mutable} = require "Property"

assertType = require "assertType"
Reaction = require "Reaction"
hook = require "hook"

shift = Array::shift

module.exports = (type) ->
  type.defineMethods typeImpl.defineMethods

# This is defined on each modx_TypeBuilder.
typeImpl = {}

typeImpl.defineMethods =

  isRenderPrevented: (func) ->

    assertType func, Function

    if @_isRenderPrevented
      throw Error "'isRenderPrevented' is already defined!"

    mutable.define this, "_isRenderPrevented", {value: func}

    delegate = @_delegate
    delegate.defineMethods {isRenderPrevented: func}
    delegate.willBuild instImpl.willBuild
    delegate.defineValues instImpl.defineValues
    delegate.defineReactions instImpl.defineReactions
    return

# This is defined on each instance of a modx_Type.
instImpl = {}

instImpl.defineValues =

  __needsRender: no

instImpl.defineReactions = ->

  __shouldRender:
    cacheResult: yes
    get: => not @isRenderPrevented()
    didSet: (shouldRender) =>
      if shouldRender and @__needsRender
        @__needsRender = no
        try @view.forceUpdate()
      return

instImpl.willBuild = ->
  @didBuild instImpl.didBuild

instImpl.didBuild = (type) ->
  hook type.prototype, "__render", gatedRender
  hook type.prototype, "__shouldUpdate", gatedRender

# Must be used with `hook()`
gatedRender = ->

  # Allow the render to go through
  if @__shouldRender.value
    orig = shift.call arguments
    return orig.call this

  # Wait for `isRenderPrevented`
  @__needsRender = yes
  return no
