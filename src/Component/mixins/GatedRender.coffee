
Reaction = require "../../../Reaction/Reaction"
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

    @_viewType.defineValues instanceValues
    @_viewType.defineReactions instanceReactions
    @_viewType.defineMethods { isRenderPrevented }

    @willBuild typePhases.build

    return

typePhases =

  willBuild: ->
    hook this, "_render", gatedRender
    hook this, "_shouldUpdate", gatedRender

instanceValues =

  needsRender: no

instanceReactions =

  shouldRender: ->
    get: => not @isRenderPrevented.call @context
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
