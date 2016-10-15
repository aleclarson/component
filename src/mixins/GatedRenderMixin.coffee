
{mutable} = require "Property"

assertType = require "assertType"
Reaction = require "Reaction"
Builder = require "Builder"
sync = require "sync"

# This is applied to the Component.Builder constructor
typeMixin = Builder.Mixin()

typeMixin.defineMethods

  isRenderPrevented: (func) ->

    assertType func, Function

    if @_isRenderPrevented
      throw Error "'isRenderPrevented' is already defined!"

    delegate = @_delegate
    delegate.defineMethods {isRenderPrevented: func}
    delegate.addMixin instanceMixin.apply

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
    hook type.prototype,
      __render: gatedRender
      __shouldUpdate: gatedRender

#
# Helpers
#

hook = (obj, methods) ->
  sync.each methods, (method, key) ->
    orig = obj[key]
    value = -> method.call this, orig, arguments
    mutable.define obj, key, {value}
  return

# Must be used with `hook()`
gatedRender = (orig, args) ->

  # Allow the render to go through
  if @__shouldRender.value
    return orig.apply this, args

  # Wait for `isRenderPrevented`
  @__needsRender = yes
  return null
