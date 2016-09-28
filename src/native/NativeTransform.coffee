
isType = require "isType"
Type = require "Type"

NativeValue = require "./NativeValue"
NativeMap = require "./NativeMap"

type = Type "NativeTransform"

type.inherits NativeMap

type.defineArgs
  values: Array.isRequired

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
      [index, key] = key.split "."
      transform = transforms[index] ?= {}
      transform[key] = value

    for key, nativeValue of @__nativeValues
      [index, key] = key.split "."
      transform = transforms[index] ?= {}
      transform[key] = nativeValue.value

    return transforms

  __attachValue: (transform, index) ->

    return if not isType transform, Object

    for key, value of transform

      key = index + "." + key

      if value instanceof NativeValue
        @__attachNativeValue value, key
      else @__values[key] = value

    return

  # All values are refreshed when attaching new values.
  __detachOldValues: (newValues) ->
    @detach()

module.exports = type.build()
