
NamedFunction = require "NamedFunction"
setKind = require "setKind"
setType = require "setType"
Type = require "Type"

ComponentTypeBuilder = require "./Builder"

module.exports =
ComponentType = NamedFunction "ComponentType", (name) ->

  self = ComponentTypeBuilder name

  self.didBuild (type) ->
    Type.augment type, yes
    setType type, ComponentType

  return self

setKind ComponentType, Type
