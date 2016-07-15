
fromArgs = require "fromArgs"
isType = require "isType"
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

  _propTypes: fromArgs 1

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
