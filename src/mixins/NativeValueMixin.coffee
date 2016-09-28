
{frozen, mutable} = require "Property"

ValueMapper = require "ValueMapper"
assertType = require "assertType"
Builder = require "Builder"
isType = require "isType"
isDev = require "isDev"
bind = require "bind"
sync = require "sync"

NativeValue = require "../native/NativeValue"

# This is applied to the Component.Builder constructor
typeMixin = Builder.Mixin()

typeMixin.defineMethods

  defineNativeValues: (nativeValues) ->
    assertType nativeValues, Object.or Function

    delegate = @_delegate
    if not delegate.__hasNativeValues
      mutable.define delegate, "__hasNativeValues", {value: yes}
      kind = delegate._kind
      unless kind and kind::__hasNativeValues
        delegate.didBuild baseImpl.didBuild
        delegate.initInstance baseImpl.initInstance

    if isType nativeValues, Object
      nativeValues = sync.map nativeValues, (value) ->
        if isType value, Function
          return -> bind.func value, this
        return value

    nativeValues = ValueMapper
      values: nativeValues
      define: (obj, key, value) ->
        return if value is undefined
        unless value instanceof NativeValue
          value = NativeValue value, obj.constructor.name + "." + key
        if isDev then frozen.define obj, key, {value}
        else obj[key] = value
        obj.__nativeKeys.push key
        value.__attach()
        return

    delegate._phases.init.push (args) ->
      nativeValues.define this, args
    return

module.exports = typeMixin.apply

# This is defined on the first type (in its inheritance chain) to call `defineNativeValues`.
baseImpl = {}

baseImpl.didBuild = (type) ->
  frozen.define type.prototype, "__hasNativeValues", { value: yes }

baseImpl.initInstance = ->
  frozen.define this, "__nativeKeys", value: []
