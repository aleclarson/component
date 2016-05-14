
require "isDev"

# { throwFailure } = require "failure"
# flattenStyle = require "flattenStyle"

assertType = require "assertType"
isType = require "isType"
assert = require "assert"
sync = require "sync"
Type = require "Type"

NativeTransform = require "./Transform"
NativeMap = require "./Map"
Style = require "../React/Style"

type = Type "NativeStyle"

type.inherits NativeMap

type.argumentTypes =
  values: Style

type.createInstance ->
  return NativeMap {}

type.initInstance (values) ->

  @attach values

type.defineMethods

  __attachValue: (value, key) ->

    if key is "transform"
      return unless Array.isArray value
      return if @__nativeMaps[key]
      value = NativeTransform value

    NativeMap::__attachValue.call this, value, key

module.exports = type.build()

  # attach: (newValues) ->
  #
  #   assertType newValues, Style
  #
  #   newValues = flattenStyle newValues
  #
  #   # if __DEV__
  #   try newValues = sync.filter newValues, (value, key) => value?
  #   catch error
  #     try throwFailure error, { newValues, style: this }
  #
  #   NativeMap::attach.call this, newValues

  # __getValues: ->
  #
  #   values = NativeMap::__getValues.call this
  #
  #   # if __DEV__
  #   sync.each values, (value, key) =>
  #     assert value?, { key, values, style: this, reason: "Value must be defined!" }
  #
  #   return values
