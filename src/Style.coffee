
{ Void, Validator, isType } = require "type-utils"
{ throwFailure } = require "failure"

valueTypes = [ Object, Array, Number, Function, Void ]

module.exports =
Style = Validator "Style",

  validate: (value, key) ->
    return yes if isType value, valueTypes
    return { key, value, type: Style }

  fail: (values) ->
    if values.key then error = TypeError "'#{values.key}' must be a Style!"
    else error = TypeError "Expected a Style."
    throwFailure error, values
