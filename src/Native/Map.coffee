
cloneObject = require "cloneObject"
assertType = require "assertType"
getArgProp = require "getArgProp"
isType = require "isType"
Event = require "Event"
Type = require "Type"

NativeValue = require "./Value"

type = Type "NativeMap"

type.defineProperties

  values: get: ->
    @__getValues()

type.defineFrozenValues

  didSet: -> Event()

type.defineValues

  __values: getArgProp 0

  __nativeMaps: -> {}

  __nativeValues: -> {}

  __nativeListeners: -> {}

type.defineMethods

  attach: (newValues) ->
    @__detachOldValues newValues
    @__attachNewValues newValues
    return

  detach: ->
    @__detachNativeValues()
    @__detachNativeMaps()
    @__nativeMaps = {}
    @__nativeValues = {}
    @__nativeListeners = {}
    return

  __didSet: (newValues) ->
    @didSet.emit newValues

  __getValues: ->

    values = cloneObject @__values

    for key, nativeValue of @__nativeValues
      values[key] = nativeValue.value

    for key, nativeMap of @__nativeMaps
      values[key] = nativeMap.values

    return values

  __attachValue: (value, key) ->

    if isType value, NativeValue.Kind
      return if @__nativeValues[key]?
      @__nativeValues[key] = value
      @__attachNativeValue value, key
      return

    if isType value, Object
      values = value
      value = @__nativeMaps[key] or NativeMap {}
      value.attach values

    if isType value, NativeMap.Kind
      return if @__nativeMaps[key]?
      @__nativeMaps[key] = value
      @__attachNativeValue value, key
      return

    @__values[key] = value
    return

  __attachNewValues: (newValues) ->
    return if not newValues
    for key, value of newValues
      @__attachValue value, key
    return

  __detachOldValues: (newValues) ->

    assertType newValues, Object

    nativeValues = @__nativeValues
    for key, nativeValue of nativeValues
      continue if nativeValue is newValues[key]
      @__detachNativeValue nativeValue, key
      delete nativeValues[key]

    nativeMaps = @__nativeMaps
    for key, nativeMap of nativeMaps

      # Detach native maps recursively.
      if nativeMap is newValues[key]
        nativeMap._detachOldValues newValues[key]
        continue

      @__detachNativeValue nativeMap, key
      delete nativeMaps[key]

    return

  __detachNativeValues: ->
    for key, nativeValue of @__nativeValues
      @__detachNativeValue nativeValue, key
    return

  __detachNativeMaps: ->
    for key, nativeMap of @__nativeMaps
      @__detachNativeValue nativeMap, key
      nativeMap.detach()
    return

  __attachNativeValue: (nativeValue, key) ->
    @__nativeListeners[key] = nativeValue.didSet (newValue) =>
      newValues = {}
      newValues[key] = newValue
      @__didSet newValues
    return

  __detachNativeValue: (nativeValue, key) ->
    @__nativeListeners[key].stop()
    delete @__nativeListeners[key]
    return

module.exports = NativeMap = type.build()
