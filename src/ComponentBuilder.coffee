
ReactComponent = require "ReactComponent"
assertType = require "assertType"
Builder = require "Builder"
Type = require "Type"

ElementType = require "./utils/ElementType"

type = Type "modx_ComponentBuilder"

type.inherits Builder

type.trace()

type.defineGetters

  _delegate: -> this

type.definePrototype

  _defaultKind: ReactComponent

type.overrideMethods

  inherits: (kind) ->
    if kind.componentType
      kind = kind.componentType
    @__super arguments

  build: ->
    componentType = @__super arguments
    elementType = ElementType componentType
    if statics = @_statics
      Object.assign elementType, statics
      Object.assign componentType, statics
    return elementType

  defineStatics: (statics) ->
    assertType statics, Object
    @_statics ?= {}
    Object.assign @_statics, statics
    return

  _defaultBaseCreator: (args) ->
    instance = Builder::_defaultBaseCreator.call null, args
    ReactComponent.apply instance, args
    return instance

type.addMixins [
  require "./mixins/StyleMixin"
  require "./mixins/PropsMixin"
  require "./mixins/LifecycleMixin"
  require "./mixins/AnimatedMixin"
  require "./mixins/ReactionMixin"
  require "./mixins/ListenerMixin"
  require "./mixins/GatedRenderMixin"
]

module.exports = type.build()
