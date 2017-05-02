
ReactComponent = require "react/lib/ReactComponent"

assertType = require "assertType"
Builder = require "Builder"
Type = require "Type"

ElementType = require "../utils/ElementType"

type = Type "modx_Component"

type.inherits Builder

type.trace()

type.defineStatics

  Mixin: require "./Mixin"

type.defineGetters

  _delegate: -> this

type.definePrototype

  _defaultKind: ReactComponent

type.overrideMethods

  inherits: (kind) ->
    kind = kind.componentType if kind.componentType
    return @__super arguments

  build: ->
    componentType = @__super arguments
    elementType = ElementType componentType
    @_statics.apply elementType
    return elementType

type.defineMethods

  _defaultCreator: do ->
    createInstance = Builder::_rootCreator
    return ->
      instance = createInstance()
      ReactComponent.apply instance, arguments
      return instance

type.addMixins [
  require "./StyleMixin"
  require "./PropsMixin"
  require "./LifecycleMixin"
  require "./AnimatedMixin"
  require "./ReactionMixin"
  require "./ListenerMixin"
  require "./GatedRenderMixin"
]

module.exports = type.build()
