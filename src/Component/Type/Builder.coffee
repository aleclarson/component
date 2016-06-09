
assertType = require "assertType"
Reaction = require "reaction"
isType = require "isType"
assert = require "assert"
define = require "define"
Type = require "Type"

Component = require ".."

type = Type "ComponentTypeBuilder"

type.inherits Type.Builder

type._initInstance.unshift ->
  @_tracer.trace()

type.overrideMethods

  inherits: (kind) ->

    @__super arguments

    if kind instanceof Component.Type
      @_componentType.inherits kind.View

    return

type.addMixins [
  require "./ViewMixin"
]

module.exports = type.build()
