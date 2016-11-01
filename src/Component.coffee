
ReactComponent = require "ReactComponent"
NamedFunction = require "NamedFunction"
assertType = require "assertType"
Builder = require "Builder"
setKind = require "setKind"
Mixin = require "Mixin"
bind = require "bind"

modx_ComponentBuilder = require "./ComponentBuilder"
ElementType = require "./utils/ElementType"

modx_Component = NamedFunction "modx_Component", (name) ->
  componentType = modx_ComponentBuilder name
  build = bind.method componentType, "build"
  componentType.build = -> ElementType build()
  return componentType

module.exports = setKind modx_Component, ReactComponent

modx_Component.Mixin = Mixin.create
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
