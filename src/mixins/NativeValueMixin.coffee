
{frozen} = require "Property"

ValueMapper = require "ValueMapper"
assertType = require "assertType"
isType = require "isType"

NativeValue = require "../native/NativeValue"

module.exports = (type) ->
  type.defineMethods typeImpl.methods

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.methods =

  defineNativeValues: (nativeValues) ->

    assertType nativeValues, Object

    delegate = @_delegate

    if not delegate.__hasNativeValues
      frozen.define delegate, "__hasNativeValues", { value: yes }
      kind = delegate._kind
      unless kind and kind::__hasNativeValues
        delegate._didBuild.push baseImpl.didBuild
        delegate._initInstance.push baseImpl.initInstance
        @_willMount.push baseImpl.attachNativeValues
        @_willUnmount.push baseImpl.detachNativeValues

    nativeValues = ValueMapper
      values: nativeValues
      define: (obj, key, value) ->
        return if value is undefined
        obj.__nativeKeys.push key
        frozen.define this, key, value:
          if value instanceof NativeValue then value
          else NativeValue value, @constructor.name + "." + key

    delegate._initInstance.push (args) ->
      nativeValues.define this, args
    return

#
# The 'base' is the first type in the inheritance chain to define native values.
#

baseImpl = {}

baseImpl.didBuild = (type) ->
  frozen.define type.prototype, hasNativeValues, { value: yes }

baseImpl.initInstance = ->
  frozen.define this, "__nativeKeys",
    value: Object.create null

baseImpl.attachNativeValues = ->
  for key in @__nativeKeys
    this[key].__attach()
  return

baseImpl.detachNativeValues = ->
  for key in @__nativeKeys
    this[key].__detach()
  return
