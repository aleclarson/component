
ReactComponent = require "ReactComponent"
assertType = require "assertType"
Builder = require "Builder"
Type = require "Type"

Component = require "."

type = Type "ComponentBuilder"

type.inherits Builder

type._initInstance.unshift ->
  @_tracer.trace()
  @_willBuild.push ->
    @_kind ?= ReactComponent

type.definePrototype

  # 'Type.Builder' overrides this.
  _delegate: get: -> this

type.overrideMethods

  __createBaseObject: (args) ->
    instance = Builder::__createBaseObject.apply null, arguments
    ReactComponent.apply instance, args
    return instance

type.addMixins [
  require "./PropsMixin"
  require "./LifecycleMixin"
  require "./StylesMixin"
  require "./NativeValueMixin"
  require "./ListenerMixin"
  require "./ReactionMixin"
  require "./GatedRenderMixin"
]

module.exports = type.build()
