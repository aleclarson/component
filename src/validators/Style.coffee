
Validator = require "Validator"
wrongType = require "wrongType"
isType = require "isType"

validTypes = Object.or Array

module.exports = Validator "ReactStyle",

  test: (value) ->
    return isType value, validTypes

  assert: (value, key) ->
    return if @test value
    return wrongType validTypes, key
