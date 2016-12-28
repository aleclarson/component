
ReactComponent = require "ReactComponent"
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
    if kind.componentType
      kind = kind.componentType
    @__super arguments

  defineStatics: (statics) ->
    assertType statics, Object
    @_statics ?= {}
    Object.assign @_statics, statics
    return

  build: ->
    componentType = @__super arguments
    elementType = ElementType componentType
    if statics = @_statics
      Object.assign elementType, statics
      Object.assign componentType, statics
    return elementType

  _defaultBaseCreator: do ->
    createInstance = Builder::_defaultBaseCreator
    return (args) ->
      instance = createInstance args
      ReactComponent.apply instance, args
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
