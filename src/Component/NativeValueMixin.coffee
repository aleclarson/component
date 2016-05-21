
assertType = require "assertType"
Property = require "Property"
isType = require "isType"
define = require "define"

NativeValue = require "../Native/Value"

module.exports = (type) ->
  type.defineMethods typeMethods

typeMethods =

  defineNativeValues: (values) ->

    assertType values, Object

    if not @_hasNativeValues
      define this, "_hasNativeValues", yes

      @_initInstance.push ->
        define this, "__nativeValues", []

      @willMount ->
        for key in @__nativeValues
          this[key].__attach()
        return

      @willUnmount ->
        for key in @__nativeValues
          this[key].__detach()
        return

    computed = Object.create null
    computed[key] = yes for key, value of values when isType value, Function

    prop = Property { frozen: yes }
    @_initInstance.push (args) ->
      for key, value of values
        value = value.apply this, args if computed[key]
        continue if value is undefined
        @__nativeValues.push key
        prop.define this, key,
          if value instanceof NativeValue then value
          else NativeValue value, @constructor.name + "." + key
      return
