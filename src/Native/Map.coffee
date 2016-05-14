
assertType = require "assertType"
isType = require "isType"
Event = require "event"
Type = require "Type"
sync = require "sync"

NativeValue = require "./Value"

type = Type "NativeMap"

type.defineProperties

  values: get: ->
    @__getValues()

type.defineFrozenValues

  didSet: -> Event()

type.defineValues

  __values: (values) -> values

  __nativeMaps: -> {}

  __nativeValues: -> {}

  __nativeListeners: -> {}

type.defineMethods

  attach: (newValues) ->
    @__detachOldValues newValues
    @__attachNewValues newValues

  detach: ->

    @__detachNativeValues()
    @__detachNativeMaps()

    @__nativeMaps = {}
    @__nativeValues = {}
    @__nativeListeners = {}

  __didSet: (newValues) ->
    @didSet.emit newValues

  __getValues: ->

    values = {}

    sync.each @__values, (value, key) ->
      values[key] = value

    sync.each @__nativeValues, (nativeValue, key) ->
      values[key] = nativeValue.value

    sync.each @__nativeMaps, (nativeMap, key) ->
      values[key] = nativeMap.values

    values

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

  __attachNewValues: (newValues) ->
    return unless newValues?
    sync.each newValues, (value, key) =>
      @__attachValue value, key

  __detachOldValues: (newValues) ->

    assertType newValues, Object

    sync.each @__nativeValues, (nativeValue, key) =>
      if nativeValue isnt newValues[key]
        @__detachNativeValue nativeValue, key
        delete @__nativeValues[key]

    sync.each @__nativeMaps, (nativeMap, key) =>
      if nativeMap isnt newValues[key]
        @__detachNativeValue nativeMap, key
        delete @__nativeMaps[key]
      else
        nativeMap._detachOldValues newValues[key]

  __detachNativeValues: ->
    sync.each @__nativeValues, (nativeValue, key) =>
      @__detachNativeValue nativeValue, key

  __detachNativeMaps: ->
    sync.each @__nativeMaps, (nativeMap, key) =>
      @__detachNativeValue nativeMap, key
      nativeMap.detach()

  __attachNativeValue: (nativeValue, key) ->
    @__nativeListeners[key] = nativeValue.didSet (newValue) =>
      newValues = {}
      newValues[key] = newValue
      @__didSet newValues

  __detachNativeValue: (nativeValue, key) ->
    @__nativeListeners[key].stop()
    delete @__nativeListeners[key]

module.exports = NativeMap = type.build()
