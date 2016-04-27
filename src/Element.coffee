
{ throwFailure } = require "failure"
{ Validator } = require "type-utils"

ReactElement = require "ReactElement"

module.exports =
Element = Validator "Element",

  validate: (value, key) ->
    return yes if ReactElement.isValidElement value
    return { key, value, type: Element }

  fail: (values) ->
    if values.key then error = TypeError "'#{values.key}' must be a ReactElement!"
    else error = TypeError "Expected a ReactElement."
    throwFailure error, values
