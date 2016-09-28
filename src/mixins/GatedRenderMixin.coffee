
{mutable} = require "Property"

assertType = require "assertType"
Reaction = require "Reaction"
Builder = require "Builder"
hook = require "hook"

# This is applied to the Component.Builder constructor
typeMixin = Builder.Mixin()

typeMixin.defineMethods

  isRenderPrevented: (func) ->

    assertType func, Function

    if @_isRenderPrevented
      throw Error "'isRenderPrevented' is already defined!"

    delegate = @_delegate
    delegate.defineMethods {isRenderPrevented: func}
    delegate.addMixins [
      instanceMixin.apply
    ]

    mutable.define this, "_isRenderPrevented", {value: func}
    return

module.exports = typeMixin.apply

# This is applied to every Component.Builder
instanceMixin = Builder.Mixin()

instanceMixin.defineValues ->

  __needsRender: no

  __shouldRender: Reaction
    cacheResult: yes
    get: => not @isRenderPrevented()
    didSet: (shouldRender) =>
      if shouldRender and @__needsRender
        @__needsRender = no
        try @view.forceUpdate()
      return

instanceMixin.initInstance ->
  @__shouldRender.start()

instanceMixin.willBuild ->
  @didBuild (type) ->
    hook type.prototype, "__render", gatedRender
    hook type.prototype, "__shouldUpdate", gatedRender

#
# Helpers
#

shift = Array::shift

# Must be used with `hook()`
gatedRender = ->

  # Allow the render to go through
  if @__shouldRender.value
    orig = shift.call arguments
    return orig.call this

  # Wait for `isRenderPrevented`
  @__needsRender = yes
  return no
