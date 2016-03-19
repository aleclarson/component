
{ throwFailure } = require "failure"

{ Validator, isType } = require "type-utils"

ReactElement = require "ReactElement"

Element = Validator "Element", -> (value, key) ->

  return if ReactElement.isValidElement value

  data = if isType(key, Object) then key else { key }
  data.value = value
  data.type = type
  reason =
    if data.key? then "'#{data.key}' must be a ReactElement."
    else "Expected a ReactElement."
  throwFailure TypeError(reason), data

module.exports = Element()
