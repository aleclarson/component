
{frozen} = require "Property"

ValueMapper = require "ValueMapper"
assertType = require "assertType"
isType = require "isType"
bind = require "bind"
sync = require "sync"

NativeValue = require "../native/NativeValue"

module.exports = (type) ->
  type.defineMethods typeImpl.defineMethods

#
# The 'type' is the Component.Builder constructor
#

typeImpl =

  defineMethods:

    defineNativeValues: (nativeValues) ->

      assertType nativeValues, Object.or Function

      delegate = @_delegate

      if not delegate.__hasNativeValues
        frozen.define delegate, "__hasNativeValues", { value: yes }
        kind = delegate._kind
        unless kind and kind::__hasNativeValues
          delegate.didBuild baseImpl.didBuild
          delegate.initInstance baseImpl.initInstance
          @_willMount.push baseImpl.attachNativeValues
          @_willUnmount.push baseImpl.detachNativeValues

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
          frozen.define obj, key, {value}
          obj.__nativeKeys.push key
          return

      delegate._initPhases.push (args) ->
        nativeValues.define this, args
      return

#
# The 'base' is the first type in the inheritance chain to define native values.
#

baseImpl =

  didBuild: (type) ->
    frozen.define type.prototype, "__hasNativeValues", { value: yes }

  initInstance: ->
    frozen.define this, "__nativeKeys", value: []

  attachNativeValues: ->
    for key in @__nativeKeys
      this[key].__attach()
    return

  detachNativeValues: ->
    for key in @__nativeKeys
      this[key].__detach()
    return
