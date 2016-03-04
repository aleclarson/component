
{ Void, Validator, isType } = require "type-utils"

{ throwFailure } = require "failure"

Style = Validator "Style", -> (value, key) ->
  return if isType value, [ Object, Array, Number, Function, Void ]
  error = TypeError "'#{key}' must be a Style."
  throwFailure error, { key, value }

module.exports = Style()
