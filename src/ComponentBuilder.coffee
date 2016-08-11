
ReactComponent = require "ReactComponent"
assertType = require "assertType"
Builder = require "Builder"
Type = require "Type"

type = Type "modx_ComponentBuilder"

type.inherits Builder

type.trace()

type.initInstance ->
  @_defaultKind = ReactComponent

type.defineGetters

  # 'modx_TypeBuilder' overrides this.
  _delegate: -> this

type.overrideMethods

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
