
assertType = require "assertType"
Reaction = require "reaction"
assert = require "assert"
hook = require "hook"

shift = Array::shift

module.exports = (type) ->
  type.defineValues typeValues
  type.defineMethods typeMethods

typeValues =

  _isRenderPrevented: null

typeMethods =

  isRenderPrevented: (isRenderPrevented) ->

    assertType isRenderPrevented, Function

    assert not @_isRenderPrevented, "'isRenderPrevented' is already defined!"
    @_isRenderPrevented = isRenderPrevented

    @defineValues instanceValues
    @defineReactions instanceReactions
    @defineMethods { isRenderPrevented }

    @_willBuild.push typePhases.build
    return

typePhases =

  willBuild: ->
    hook this, "_render", gatedRender
    hook this, "_shouldUpdate", gatedRender

instanceValues =

  needsRender: no

instanceReactions =

  shouldRender: ->
    get: => not @isRenderPrevented()
    didSet: (shouldRender) =>
      return unless @needsRender and shouldRender
      @needsRender = no
      try @forceUpdate()

# Must be used with 'hook()'.
gatedRender = ->

  # Allow the render to go through.
  if @view.shouldRender.value
    orig = shift.call arguments
    return orig.apply this, arguments

  # Wait for 'isRenderPrevented'
  @needsRender = yes
  return no
