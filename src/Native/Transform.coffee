
require "isDev"

isConstructor = require "isConstructor"
Type = require "Type"

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

type.overrideMethods

  # All values are refreshed when attaching new values.
  __didSet: (newValues) ->
    @didSet.emit @values

  __getValues: ->

    transforms = []

    for key, value of @__values
      [ index, key ] = key.split "."
      transform = transforms[index] ?= {}
      transform[key] = value

    for key, nativeValue of @__nativeValues
      [ index, key ] = key.split "."
      transform = transforms[index] ?= {}
      transform[key] = nativeValue.value

    return transforms

  __attachValue: (transform, index) ->

    return if not isConstructor transform, Object

    for key, value of transform

      key = index + "." + key

      if value instanceof NativeValue
        @__nativeValues[key] = value
        @__attachNativeValue value, key
        return

      @__values[key] = value

  # All values are refreshed when attaching new values.
  __detachOldValues: (newValues) ->
    @detach()

module.exports = type.build()
