
{ throwFailure } = require "failure"
{ Validator } = require "type-utils"

ReactElement = require "ReactElement"

module.exports =
Children = Validator "Children",

  validate: (value, key) ->
    return yes if value is undefined
    return yes if ReactElement.isValidElement value
    return yes if Array.isArray value
    return { key, value, type: Children }

  fail: (values) ->
    if values.key then error = TypeError "'#{values.key}' must be an Array or ReactElement!"
    else error = TypeError "Expected an Array or ReactElement."
    throwFailure error, values
