
require "isDev"

{ isType } = require "type-utils"

Type = require "Type"
sync = require "sync"

NativeValue = require "./Value"
NativeMap = require "./Map"

type = Type "NativeTransform"

type.inherits NativeMap

type.argumentTypes =
  values: Array

type.createInstance ->
  return NativeMap {}

type.initInstance (values) ->

  @attach values

type.defineMethods

  # All values are refreshed when attaching new values.
  __didSet: (newValues) ->
    @didSet.emit @values

  __getValues: ->

    values = []

    sync.each @__values, (value, key) ->
      [ index, key ] = key.split "."
      transform = values[index] ?= {}
      transform[key] = value

    sync.each @__nativeValues, (nativeValue, key) ->
      [ index, key ] = key.split "."
      transform = values[index] ?= {}
      transform[key] = nativeValue.value

    values

  _attachValue: (transform, index) ->

    return unless isType transform, Object

    sync.each transform, (value, key) =>

      key = index + "." + key

      if isType value, NativeValue.Kind
        @__nativeValues[key] = value
        @__attachNativeValue value, key
        return

      @__values[key] = value

  # All values are refreshed when attaching new values.
  _detachOldValues: (newValues) ->
    @detach()

module.exports = type.build()
