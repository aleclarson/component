
{ isType, isKind, assertType } = require "type-utils"
{ sync } = require "io"

Factory = require "factory"

NativeValue = require "./NativeValue"
NativeMap = require "./NativeMap"

module.exports = Factory "NativeTransform",

  kind: NativeMap

  create: ->
    return NativeMap {}

  init: (values) ->
    assertType values, Array
    @attach values

  #
  # Internal
  #

  # All values are refreshed when attaching new values.
  _didSet: (newValues) ->
    @didSet.emit @values

  _getValues: ->

    values = []

    sync.each @_values, (value, key) ->
      [ index, key ] = key.split "."
      transform = values[index] ?= {}
      transform[key] = value

    sync.each @_nativeValues, (nativeValue, key) ->
      [ index, key ] = key.split "."
      transform = values[index] ?= {}
      transform[key] = nativeValue.value

    values

  _attachValue: (transform, index) ->

    return unless isType transform, Object

    sync.each transform, (value, key) =>

      key = index + "." + key

      if isKind value, NativeValue
        @_nativeValues[key] = value
        @_attachNativeValue value, key
        return

      @_values[key] = value

  # All values are refreshed when attaching new values.
  _detachOldValues: (newValues) ->
    @detach()
