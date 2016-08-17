
require "isDev"

assertType = require "assertType"
Reaction = require "reaction"
hook = require "hook"

shift = Array::shift

module.exports = (type) ->
  type.defineValues typeImpl.values
  type.defineMethods typeImpl.methods

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.values =

  _isRenderPrevented: null

typeImpl.methods =

  isRenderPrevented: (func) ->

    assertType func, Function

    if @_isRenderPrevented
      throw Error "'isRenderPrevented' is already defined!"

    @_isRenderPrevented = func
    @didBuild typeImpl.didBuild

    delegate = @_delegate
    delegate.defineValues instImpl.values
    delegate.defineReactions instImpl.reactions
    delegate.defineMethods { isRenderPrevented: func }
    return

typeImpl.didBuild = (type) ->
  hook type.prototype, "__render", typeImpl.gatedRender
  hook type.prototype, "__shouldUpdate", typeImpl.gatedRender

# Must be used with 'hook()'.
typeImpl.gatedRender = ->

  # Allow the render to go through.
  if @view.shouldRender.value
    orig = shift.call arguments
    return orig.call this

  # Wait for 'isRenderPrevented'
  @needsRender = yes
  return no

#
# The 'instance' is a Component.Builder
#

instImpl = {}

instImpl.values =

  needsRender: no

instImpl.reactions =

  shouldRender: ->
    get: => not @isRenderPrevented()
    didSet: (shouldRender) =>
      return unless @needsRender and shouldRender
      @needsRender = no
      try @forceUpdate()
