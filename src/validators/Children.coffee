
Validator = require "Validator"
wrongType = require "wrongType"
isType = require "isType"

Element = require "./Element"

validTypes = Element.or Array

module.exports = Validator "ReactChildren",

  test: (value) ->
    return yes if value is no
    return isType value, validTypes

  assert: (value, key) ->
    return if @test value
    return wrongType validTypes, key
