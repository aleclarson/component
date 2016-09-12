
isType = require "isType"
Type = require "Type"

NativeStyle = require "./NativeStyle"
NativeMap = require "./NativeMap"
Children = require "../validators/Children"
Style = require "../validators/Style"

type = Type "NativeProps"

type.inherits NativeMap

type.defineArgs
  props: Object.isRequired
  propTypes: Object

type.createInstance ->
  return NativeMap {}

type.defineValues

  _propTypes: (_, propTypes) -> propTypes

type.initInstance (props) ->
  @attach props

type.overrideMethods

  __attachValue: (value, key) ->

    type = @_propTypes[key] if @_propTypes

    if type is Children
      @__values[key] = value
      return

    if type is Style
      return if not value?
      return if @__nativeMaps[key]
      value = NativeStyle value

    @__super arguments

module.exports = type.build()
