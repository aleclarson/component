
{ assert, assertType, isType } = require "type-utils"

{ throwFailure } = require "failure"

sync = require "sync"

flattenStyle = require "flattenStyle"
Factory = require "factory"

NativeTransform = require "./NativeTransform"
NativeMap = require "./NativeMap"
Style = require "./Style"

module.exports = Factory "NativeStyle",

  kind: NativeMap

  create: ->
    return NativeMap {}

  init: (values) ->
    @attach values

  attach: (newValues) ->

    assertType newValues, Style

    newValues = flattenStyle newValues

    # if __DEV__
    try newValues = sync.filter newValues, (value, key) => value?
    catch error
      try throwFailure error, { newValues, style: this }

    NativeMap::attach.call this, newValues

  #
  # Internal
  #

  _getValues: ->

    values = NativeMap::_getValues.call this

    # if __DEV__
    sync.each values, (value, key) =>
      assert value?, { key, values, style: this, reason: "Value must be defined!" }

    values

  _attachValue: (value, key) ->

    if key is "transform"
      return unless isType value, Array
      return if @_nativeMaps[key]?
      value = NativeTransform value

    NativeMap::_attachValue.call this, value, key
