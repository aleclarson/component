
ReactComponent = require "ReactComponent"
NamedFunction = require "NamedFunction"
assertType = require "assertType"
Builder = require "Builder"
setKind = require "setKind"
Mixin = require "Mixin"
bind = require "bind"

ComponentBuilder = require "./ComponentBuilder"
ElementType = require "./utils/ElementType"

Component = NamedFunction "Component", (name) ->
  componentType = ComponentBuilder name
  build = bind.method componentType, "build"
  componentType.build = -> ElementType build()
  return componentType

module.exports = setKind Component, ReactComponent

Component.Mixin = Mixin.create
  extends: Builder.Mixin
  methods: [
    "defineProps"
    "replaceProps"
    "initProps"
    "render"
    "isRenderPrevented"
    "shouldUpdate"
    "willReceiveProps"
    "willMount"
    "didMount"
    "willUnmount"
    "willUpdate"
    "didUpdate"
    "defineNativeValues"
    "defineListeners"
    "defineReactions"
    "defineStyles"
    "appendStyles"
    "overrideStyles"
  ]
