
NamedFunction = require "NamedFunction"
LazyVar = require "LazyVar"
setKind = require "setKind"
setType = require "setType"
Type = require "Type"

modx_TypeBuilder = LazyVar -> require "./TypeBuilder"

modx_Type = NamedFunction "modx_Type", (name) ->

  self = modx_TypeBuilder.call name

  self.didBuild (type) ->
    setType type, modx_Type

  return self

modx_Type.Builder = modx_TypeBuilder

module.exports = setKind modx_Type, Type
