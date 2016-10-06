
isType = require "isType"
Type = require "Type"

NativeStyle = require "./NativeStyle"
NativeMap = require "./NativeMap"
Children = require "../validators/Children"
Style = require "../validators/Style"

type = Type "NativeProps"

type.inherits NativeMap

type.defineArgs
  propTypes: Object

type.createInstance ->
  return NativeMap {}

type.defineValues (propTypes) ->

  _propTypes: propTypes or {}

type.overrideMethods

  __attachValue: (value, key) ->

    type = @_propTypes[key] if @_propTypes

    if type is Children
      @__values[key] = value
      return

    if type is Style and value?
      style = @__nativeMaps[key] or NativeStyle()
      style.attach value
      @__attachNativeMap style, key
      return

    @__super arguments
    return

module.exports = type.build()
