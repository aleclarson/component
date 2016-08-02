
NamedFunction = require "NamedFunction"
LazyVar = require "LazyVar"
setKind = require "setKind"
setType = require "setType"
Type = require "Type"

modx_TypeBuilder = LazyVar -> require "./TypeBuilder"

modx_Type = NamedFunction "modx_Type", (name) ->

  self = modx_TypeBuilder.call name

  self.didBuild (type) ->
    Type.augment type, yes
    setType type, modx_Type

  return self

module.exports = setKind modx_Type, Type
