
cloneObject = require "cloneObject"
assertType = require "assertType"
isType = require "isType"
Event = require "Event"
Type = require "Type"

NativeValue = require "./NativeValue"

type = Type "NativeMap"

type.defineGetters

  values: -> @__getValues()

type.defineFrozenValues

  didSet: -> Event()

type.defineValues (values) ->

  __values: values

  __nativeMaps: {}

  __nativeValues: {}

  __nativeListeners: {}

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

type.defineHooks

  __didSet: (newValues) ->
    @didSet.emit newValues

  __getValues: ->

    values = cloneObject @__values

    for key, nativeValue of @__nativeValues
      values[key] = nativeValue.value

    for key, nativeMap of @__nativeMaps
      values[key] = nativeMap.values

    return values

  #
  # Attaching values
  #

  __attachNewValues: (newValues) ->
    return if not newValues
    for key, value of newValues
      @__attachValue value, key
    return

  __attachValue: (value, key) ->

    if value instanceof NativeValue
      @__attachNativeValue value, key
      return

    if isType value, Object
      map = @__nativeMaps[key] or NativeMap {}
      map.attach value
      @__attachNativeMap map, key
      return

    if value instanceof NativeMap
      @__attachNativeMap value, key
      return

    @__values[key] = value
    return

  __attachNativeValue: (nativeValue, key) ->
    if not @__nativeValues[key]
      @__values[key] = undefined
      @__nativeValues[key] = value
      @__attachNativeListener value, key
    return

  __attachNativeMap: (nativeMap, key) ->
    if not @__nativeMaps[key]
      @__values[key] = undefined
      @__nativeMaps[key] = value
      @__attachNativeListener value, key
    return

  __attachNativeListener: (nativeValue, key) ->

    onChange = (newValue) =>
      newValues = {}
      newValues[key] = newValue
      @__didSet newValues

    listener = nativeValue.didSet onChange
    @__nativeListeners[key] = listener.start()
    return

  #
  # Detaching values
  #

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

  __detachNativeListener: (nativeValue, key) ->
    @__nativeListeners[key].stop()
    delete @__nativeListeners[key]
    return

module.exports = NativeMap = type.build()
