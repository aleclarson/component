
{ isType, isKind, setType, assert, assertType } = require "type-utils"
{ sync } = require "io"

Immutable = require "immutable"
Factory = require "factory"
Event = require "event"

NativeValue = require "./NativeValue"

module.exports =
NativeMap = Factory "NativeMap",

  customValues:

    values: get: ->
      @_getValues()

  initFrozenValues: ->
    didSet: Event()

  initValues: (values) ->
    _values: values
    _nativeMaps: {}
    _nativeValues: {}
    _nativeListeners: {}

  attach: (newValues) ->
    @_detachOldValues newValues
    @_attachNewValues newValues

  detach: ->

    @_detachNativeValues()
    @_detachNativeMaps()

    @_nativeMaps = {}
    @_nativeValues = {}
    @_nativeListeners = {}

  #
  # Internal
  #

  _didSet: (newValues) ->
    @didSet.emit newValues

  _getValues: ->

    values = {}

    sync.each @_values, (value, key) ->
      values[key] = value

    sync.each @_nativeValues, (nativeValue, key) ->
      values[key] = nativeValue.value

    sync.each @_nativeMaps, (nativeMap, key) ->
      values[key] = nativeMap.values

    values

  _attachValue: (value, key) ->

    if isKind value, NativeValue
      return if @_nativeValues[key]?
      @_nativeValues[key] = value
      @_attachNativeValue value, key
      return

    if isType value, Object
      values = value
      value = @_nativeMaps[key] or NativeMap {}
      value.attach values

    if isKind value, NativeMap
      return if @_nativeMaps[key]?
      @_nativeMaps[key] = value
      @_attachNativeValue value, key
      return

    @_values[key] = value

  _attachNewValues: (newValues) ->
    return unless newValues?
    sync.each newValues, (value, key) =>
      @_attachValue value, key

  _detachOldValues: (newValues) ->

    assertType newValues, Object

    sync.each @_nativeValues, (nativeValue, key) =>
      if nativeValue isnt newValues[key]
        @_detachNativeValue nativeValue, key
        delete @_nativeValues[key]

    sync.each @_nativeMaps, (nativeMap, key) =>
      if nativeMap isnt newValues[key]
        @_detachNativeValue nativeMap, key
        delete @_nativeMaps[key]
      else
        nativeMap._detachOldValues newValues[key]

  _detachNativeValues: ->
    sync.each @_nativeValues, (nativeValue, key) =>
      @_detachNativeValue nativeValue, key

  _detachNativeMaps: ->
    sync.each @_nativeMaps, (nativeMap, key) =>
      @_detachNativeValue nativeMap, key
      nativeMap.detach()

  #
  # NativeValue integration
  #

  _attachNativeValue: (nativeValue, key) ->
    @_nativeListeners[key] = nativeValue.didSet (newValue) =>
      newValues = {}
      newValues[key] = newValue
      @_didSet newValues

  _detachNativeValue: (nativeValue, key) ->
    @_nativeListeners[key].stop()
    delete @_nativeListeners[key]
