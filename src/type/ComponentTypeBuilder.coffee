
assertType = require "assertType"
isType = require "isType"
assert = require "assert"
Type = require "Type"

Component = require "../Component"

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
