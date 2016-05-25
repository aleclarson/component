
assertType = require "assertType"
Property = require "Property"
Random = require "random"
isType = require "isType"
define = require "define"

NativeValue = require "../Native/Value"

hasNativeValues = Symbol "Component.hasNativeValues"

frozen = Property { frozen: yes }

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
    kind = delegate._kind

    if not delegate[hasNativeValues]
      frozen.define delegate, hasNativeValues, yes

      # Define 'this.__nativeKeys' only once in the inheritance chain.
      unless kind and kind::[hasNativeValues]

        delegate._didBuild.push (type) ->
          frozen.define type.prototype, hasNativeValues, yes

        delegate._initInstance.push ->
          frozen.define this, "__nativeKeys", Object.create null

    # Function values are used as initializers.
    computed = Object.create null
    for key, value of nativeValues
      if isType value, Function
        computed[key] = yes

    phaseId = Random.id()
    delegate._initInstance.push (args) ->
      keys = []
      for key, value of nativeValues
        value = value.apply this, args if computed[key]
        continue if value is undefined
        keys.push key
        frozen.define this, key,
          if value instanceof NativeValue then value
          else NativeValue value, @constructor.name + "." + key
      @__nativeKeys[phaseId] = keys
      return

    @_willMount.push ->
      delegate = @_delegate
      for key in delegate.__nativeKeys[phaseId]
        delegate[key].__attach()
      return

    @_willUnmount.push ->
      delegate = @_delegate
      for key in delegate.__nativeKeys[phaseId]
        delegate[key].__detach()
      return

    return
