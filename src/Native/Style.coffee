
flattenStyle = require "flattenStyle"
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

type.overrideMethods

  attach: (newValues) ->

    if Array.isArray newValues
      newValues = flattenStyle newValues

    @__super arguments

  __attachValue: (value, key) ->

    if key is "transform"
      return unless Array.isArray value
      return if @__nativeMaps[key]
      value = NativeTransform value

    @__super arguments

module.exports = type.build()
