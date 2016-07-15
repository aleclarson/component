
{ frozen } = require "Property"

assertType = require "assertType"
Random = require "random"
isType = require "isType"
define = require "define"

NativeValue = require "../Native/Value"

hasNativeValues = Symbol "Component.hasNativeValues"

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

    # Some phases must only be defined once per inheritance chain.
    if not delegate[hasNativeValues]
      frozen.define delegate, hasNativeValues, yes
      kind = delegate._kind
      unless kind and kind::[hasNativeValues]
        delegate._didBuild.push baseImpl.didBuild
        delegate._initInstance.push baseImpl.initInstance

    # Function values are used as initializers.
    computed = Object.create null
    for key, value of nativeValues
      if isType value, Function
        computed[key] = yes

    phaseId = Random.id()

    #
    # Create the NativeValue objects for each instance.
    #

    createNativeValues = (args) ->

      nativeKeys = []

      for key, value of nativeValues

        # Some properties compute a value for each instance.
        value = value.apply this, args if computed[key]

        # If 'undefined' is returned, the property should not be defined.
        continue if value is undefined

        nativeKeys.push key
        frozen.define this, key,
          if value instanceof NativeValue then value
          else NativeValue value, @constructor.name + "." + key

      @__nativeKeys[phaseId] = nativeKeys
      return

    delegate._initInstance.push createNativeValues

    #
    # Attach each NativeValue when the instance is mounted.
    #

    attachNativeValues = ->
      for key in @__nativeKeys[phaseId]
        this[key].__attach()
      return

    @_willMount.push attachNativeValues

    #
    # Detach each NativeValue when the instance is unmounted.
    #

    detachNativeValues = ->
      for key in @__nativeKeys[phaseId]
        this[key].__detach()
      return

    @_willUnmount.push detachNativeValues
    return

#
# The 'base' is the first type in the inheritance chain to define native values.
#

baseImpl = {}

baseImpl.didBuild = (type) ->
  frozen.define type.prototype, hasNativeValues, yes

baseImpl.initInstance = ->
  frozen.define this, "__nativeKeys", Object.create null
