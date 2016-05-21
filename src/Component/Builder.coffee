
ReactComponent = require "ReactComponent"
Builder = require "Builder"
Type = require "Type"

Component = require "."

type = Type "ComponentBuilder"

type.inherits Builder

type.initInstance ->
  @_willBuild.push ->
    @_kind ?= ReactComponent

type.overrideMethods

  inherits: ->
    throw Error "Cannot call 'inherits' as a ComponentBuilder!"

  createInstance: ->
    throw Error "Cannot call 'createInstance' as a ComponentBuilder!"

  __createBaseObject: (args) ->
    instance = Object.create ReactComponent.prototype
    ReactComponent.apply instance, args
    return instance

type.addMixins [
  require "./PropsMixin"
  require "./LifecycleMixin"
  require "./StyleMixin"
  require "./NativeValueMixin"
  require "./ListenerMixin"
  require "./GatedRenderMixin"
]

module.exports = type.build()
