
NamedFunction = require "NamedFunction"

TypeBuilder = require "./TypeBuilder"

module.exports =
ComponentType = NamedFunction "ComponentType", ->

  self = TypeBuilder()

  self.didBuild (type) ->
    setType type, ComponentType

  return self
