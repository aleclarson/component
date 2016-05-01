
{ isType } = require "type-utils"

Type = require "Type"

NativeStyle = require "./Style"
NativeMap = require "./Map"
Children = require "../React/Children"
Style = require "../React/Style"

type = Type "NativeProps"

type.inherits NativeMap

type.argumentTypes =
  props: Object
  propTypes: Object.Maybe

type.createInstance ->
  return NativeMap {}

type.defineValues

  _propTypes: (_, propTypes) -> propTypes

type.initInstance (props) ->

  @attach props

type.defineMethods

  __attachValue: (value, key) ->

    type = @_propTypes[key] if @_propTypes

    if (type is Children) or (key is "children")
      @__values[key] = value
      return

    if (type is Style) or (key is "style")
      return unless value?
      return if @__nativeMaps[key]
      value = NativeStyle value

    NativeMap::__attachValue.call this, value, key

module.exports = type.build()
