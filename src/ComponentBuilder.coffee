
ReactComponent = require "ReactComponent"
assertType = require "assertType"
Builder = require "Builder"
Type = require "Type"

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

  _defaultBaseCreator: (args) ->
    instance = Builder::_defaultBaseCreator.call null, args
    ReactComponent.apply instance, args
    return instance

type.addMixins [
  require "./mixins/PropsMixin"
  require "./mixins/LifecycleMixin"
  require "./mixins/StyleMixin"
  require "./mixins/NativeValueMixin"
  require "./mixins/ListenerMixin"
  require "./mixins/ReactionMixin"
  require "./mixins/GatedRenderMixin"
]

module.exports = type.build()
