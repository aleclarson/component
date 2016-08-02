
Validator = require "Validator"
wrongType = require "wrongType"
isType = require "isType"
Void = require "Void"

Element = require "./Element"

validTypes = [ Element, Array, Void ]

module.exports = Validator "ReactChildren",

  test: (value) ->
    isType value, validTypes

  assert: (value, key) ->
    return if @test value
    wrongType validTypes, key
