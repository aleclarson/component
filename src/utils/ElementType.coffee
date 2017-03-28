
ReactCurrentOwner = require "react/lib/ReactCurrentOwner"
ReactElement = require "react/lib/ReactElement"

NamedFunction = require "NamedFunction"
assertType = require "assertType"
setType = require "setType"
setKind = require "setKind"
isType = require "isType"
steal = require "steal"
has = require "has"

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
    if props? and not Object.isFrozen props

      if key = steal props, "key"
        delete props.key
        key = String key

      if ref = steal props, "ref"
        delete props.ref
        assertType ref, Function, "props.ref"

      if mixins = steal props, "mixins"
        delete props.mixins
        assertType mixins, Array, "props.mixins"
        applyMixins mixins, props

    else props = {}

    props = initProps props if initProps

    if delegate
      props.delegate = delegate

    else if has props, "delegate"
      props.delegate = null

    ReactElement.apply null, [
      componentType
      key
      ref
      null
      null
      ReactCurrentOwner.current
      props
    ]
