
require "isDev"

ReactComponent = require "ReactComponent"
NamedFunction = require "NamedFunction"
assertType = require "assertType"
setKind = require "setKind"
define = require "define"
hook = require "hook"

ComponentBuilder = require "./Builder"
ElementType = require "./ElementType"

module.exports =
Component = NamedFunction "Component", (name) ->
  self = ComponentBuilder name
  hook self, "build", build
  return self

setKind Component, ReactComponent

# A hook into 'ComponentBuilder::build'
build = (build) ->
  componentType = build.call this
  elementType = ElementType componentType
  elementType.componentType = componentType
  return elementType

define Component,

  Type: lazy: ->
    require "./Type"

  StyleMap: lazy: ->
    require "./StyleMap"
