
ReactCurrentOwner = require "react/lib/ReactCurrentOwner"
ReactElement = require "react/lib/ReactElement"

NamedFunction = require "NamedFunction"
assertType = require "assertType"
setType = require "setType"
setKind = require "setKind"
isType = require "isType"

ElementType = NamedFunction "ElementType", (componentType) ->
  assertType componentType, Function.Kind
  elementType = createType componentType
  elementType.componentType = componentType
  return setType elementType, ElementType

module.exports = setKind ElementType, Function

#
# Helpers
#

applyMixins = (mixins, props) ->
  for mixin in mixins
    continue if not mixin?
    for key, value of mixin
      if props[key] is undefined
        props[key] = value
  return

createType = (componentType) ->
  {initProps} = componentType
  return createElement = (props, delegate) ->

    assertType props, Object.Maybe, "props"
    if props?

      if Object.isFrozen props
        throw Error "'props' cannot be frozen!"

      key = props.key
      if key?
        delete props.key
        key = String key

      ref = props.ref
      if ref?
        delete props.ref
        assertType ref, Function, "props.ref"

      mixins = props.mixins
      if mixins?
        delete props.mixins
        assertType mixins, Array, "props.mixins"
        applyMixins mixins, props

    else props = {}

    props = initProps props if initProps
    props.delegate = delegate or null

    ReactElement.apply null, [
      componentType
      key
      ref
      null
      null
      ReactCurrentOwner.current
      props
    ]
