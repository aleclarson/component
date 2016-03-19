
{ isType } = require "type-utils"

Factory = require "factory"

NativeStyle = require "./NativeStyle"
NativeMap = require "./NativeMap"
Children = require "./Children"
Style = require "./Style"

module.exports = Factory "NativeProps",

  kind: NativeMap

  create: ->
    return NativeMap {}

  initValues: (props, types, setNativeProps) ->
    _types: types
    _setNativeProps: setNativeProps

  init: (props) ->
    @attach props

  #
  # Internal
  #

  _didSet: (newValues) ->
    @_setNativeProps newValues
    @didSet.emit newValues

  _attachValue: (value, key) ->

    type = @_types[key]

    if (type is Children) or (key is "children")
      @_values[key] = value
      return

    if (type is Style) or (key is "style")
      return unless value?
      try assert (isType value, Style), { value, props: this, reason: "Invalid style!" }
      return if @_nativeMaps[key]?
      value = NativeStyle value

    NativeMap::_attachValue.call this, value, key
