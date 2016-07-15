
NamedFunction = require "NamedFunction"
setKind = require "setKind"
setType = require "setType"
Type = require "Type"

TypeBuilder = require "./TypeBuilder"

module.exports =
ComponentType = NamedFunction "ComponentType", (name) ->

  self = TypeBuilder name

  self.didBuild (type) ->
    setType type, ComponentType

  return self

setKind ComponentType, Type
