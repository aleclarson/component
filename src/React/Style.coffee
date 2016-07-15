
{ throwFailure } = require "failure"

Validator = require "Validator"
wrongType = require "wrongType"
isType = require "isType"
Void = require "Void"

validTypes = [ Object, Array, Void ]

module.exports =
Style = Validator "Style",

  test: (value) ->
    isType value, validTypes

  assert: (value, key) ->
    return if @test value
    wrongType validTypes, key
