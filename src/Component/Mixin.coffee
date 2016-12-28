
Builder = require "Builder"
Mixin = require "Mixin"

module.exports = Mixin.create
  extends: Builder.Mixin
  methods: [
    "definePropDefaults"
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
    "defineAnimatedValues"
    "defineReactions"
    "defineListeners"
    "defineStyles"
    "appendStyles"
    "overrideStyles"
  ]
