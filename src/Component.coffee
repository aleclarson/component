
require "isDev"

ReactComponent = require "ReactComponent"
NamedFunction = require "NamedFunction"
assertType = require "assertType"
setKind = require "setKind"
define = require "define"
hook = require "hook"

modx_ComponentBuilder = require "./ComponentBuilder"
ElementType = require "./utils/ElementType"

modx_Component = NamedFunction "modx_Component", (name) ->
  self = modx_ComponentBuilder name
  hook self, "build", build
  return self

module.exports = setKind modx_Component, ReactComponent

# A hook into 'modx_ComponentBuilder::build'
build = (build) ->
  componentType = build.call this
  elementType = ElementType componentType
  elementType.componentType = componentType
  return elementType
