
require "isDev"

ReactCurrentOwner = require "ReactCurrentOwner"
NamedFunction = require "NamedFunction"
ReactElement = require "ReactElement"
assertType = require "assertType"
setType = require "setType"
setKind = require "setKind"
isType = require "isType"
steal = require "steal"

ElementType = NamedFunction "ElementType", (componentType) ->
  assertType componentType, Function.Kind
  elementType = createType componentType, componentType.initProps
  elementType.propTypes = componentType.propTypes
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

createType = (componentType, initProps) ->

  createElement = (props, delegate) ->

    if props?
    then assertType props, Object, "props"
    else props = {}

    key = steal props, "key", null
    if key isnt null
      key = String key unless isType key, String

    ref = steal props, "ref", null
    if ref isnt null
      assertType ref, Function, "props.ref"

    mixins = steal props, "mixins", null
    if mixins isnt null
      assertType mixins, Array, "props.mixins"
      applyMixins mixins, props

    if initProps
      props = initProps props

    if delegate
      props.delegate = delegate

    ReactElement.apply null, [
      componentType
      key
      ref
      null
      null
      ReactCurrentOwner.current
      props
    ]
