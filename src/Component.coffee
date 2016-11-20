
ReactComponent = require "ReactComponent"
NamedFunction = require "NamedFunction"
setKind = require "setKind"

Component = NamedFunction "Component", (name) ->
  return Component.Builder name

module.exports = setKind Component, ReactComponent

Component.Builder = require "./ComponentBuilder"
Component.Mixin = require "./ComponentMixin"
