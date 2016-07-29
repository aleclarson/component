
ReactElement = require "ReactElement"
Validator = require "Validator"
wrongType = require "wrongType"

module.exports = Validator "ReactElement",

  test: (value) ->
    ReactElement.isValidElement value

  assert: (value, key) ->
    return if @test value
    wrongType this, key
