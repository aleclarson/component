
flattenStyle = require "flattenStyle"
Type = require "Type"

NativeTransform = require "./NativeTransform"
NativeMap = require "./NativeMap"
Style = require "../validators/Style"

type = Type "NativeStyle"

type.inherits NativeMap

type.defineArgs
  values: Style.isRequired

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
