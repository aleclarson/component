
flattenStyle = require "flattenStyle"
Type = require "Type"

NativeTransform = require "./NativeTransform"
NativeMap = require "./NativeMap"

type = Type "NativeStyle"

type.inherits NativeMap

type.createInstance ->
  return NativeMap {}

type.overrideMethods

  attach: (newValues) ->

    if Array.isArray newValues
      newValues = flattenStyle newValues

    @__super arguments
    return this

  __attachValue: (value, key) ->

    if key is "transform" and Array.isArray value
      transform = @__nativeMaps[key] or NativeTransform()
      transform.attach value
      @__attachNativeMap transform, key
      return

    @__super arguments
    return

module.exports = type.build()
