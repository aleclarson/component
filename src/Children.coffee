
{ Void, Validator, isType } = require "type-utils"

{ throwFailure } = require "failure"

ReactElement = require "ReactElement"

Children = Validator "Children", -> (value, key) ->
  return if ReactElement.isValidElement value
  return if isType value, [ Array, Void ]
  error = TypeError "'#{key}' must be an Array or ReactElement."
  throwFailure error, { key, value }

module.exports = Children()
