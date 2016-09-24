
require "isDev"

ReactCurrentOwner = require "ReactCurrentOwner"
NamedFunction = require "NamedFunction"
emptyFunction = require "emptyFunction"
ReactElement = require "ReactElement"
assertType = require "assertType"
setType = require "setType"
setKind = require "setKind"
isType = require "isType"
steal = require "steal"
sync = require "sync"

# Created for every instance of 'Component.Type'
# Created for every non-delegated subclass of 'Component'
ElementType = NamedFunction "ElementType", (componentType, initProps) ->

  assertType componentType, Function.Kind
  assertType initProps, Function.Maybe

  initProps ?= emptyFunction.thatReturnsArgument

  elementType = (props = {}) ->

    if props?
    then assertType props, Object, "props"
    else props = {}

    elementKey = steal props, "key", null
    if elementKey isnt null
      if not isType elementKey, String
        elementKey = String elementKey

    elementRef = steal props, "ref", null
    elementRef? and assertType elementRef, Function, "props.ref"

    if props.mixins?
      mixins = steal props, "mixins"
      assertType mixins, Array, "props.mixins"
      applyMixins mixins, props

    props = initProps props
    ReactElement.apply null, [
      componentType
      elementKey
      elementRef
      null
      null
      ReactCurrentOwner.current
      props
    ]

  elementType.componentType = componentType
  return setType elementType, ElementType

module.exports = setKind ElementType, Function

#
# Helpers
#

applyMixins = (mixins, props) ->
  for mixin in mixins
    for key, value of mixin
      if props[key] isnt undefined
        props[key] = value
  return
