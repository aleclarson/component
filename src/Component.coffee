
ReactComponent = require "ReactComponent"
NamedFunction = require "NamedFunction"
assertType = require "assertType"
setKind = require "setKind"
bind = require "bind"

modx_ComponentBuilder = require "./ComponentBuilder"
ElementType = require "./utils/ElementType"

modx_Component = NamedFunction "modx_Component", (name) ->
  componentType = modx_ComponentBuilder name
  build = bind.method componentType, "build"
  componentType.build = -> ElementType build()
  return componentType

module.exports = setKind modx_Component, ReactComponent
