
{ Void, Validator, isType } = require "type-utils"

reportFailure = require "report-failure"

Style = Validator "Style", -> (value, key) ->
  return if isType value, [ Object, Array, Number, Function, Void ]
  error = TypeError "'#{key}' must be a Style."
  reportFailure error, { key, value }

module.exports = Style()
