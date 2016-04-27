
{ assert, isType, Void } = require "type-utils"

Factory = require "factory"

NativeValue = require "./NativeValue"

module.exports = Factory "NativeArray",

  kind: NativeValue

  create: -> {} # Just pretending to be a NativeValue.

  disableStateHistory: yes

  optionTypes:
    keyPath: [ String, Void ]
    length: Number

  initArguments: (keyPath, length) ->
    if isType keyPath, Number
      length = keyPath
      keyPath = null
    [ { keyPath, length } ]

  initFrozenValues: (options) ->
    length: options.length
    _array: []

  initValues: (options) ->
    keyPath: options.keyPath

  get: (index) ->
    assert (index >= 0) and (index < @length), { index, @length, reason: "Index is out of bounds!" }
    nativeValue = @_array[index]
    unless nativeValue?
      nativeValue = @_array[index] =
        NativeValue null, (@keyPath or "") + ("" + index)
      nativeValue.index = index
    nativeValue

  detach: ->
    sync.each @_array, (nativeValue) ->
      nativeValue.detach()
