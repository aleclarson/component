
require "isDev"

ReactCurrentOwner = require "ReactCurrentOwner"
NamedFunction = require "NamedFunction"
emptyFunction = require "emptyFunction"
ReactElement = require "ReactElement"
assertType = require "assertType"
Property = require "Property"
setType = require "setType"
setKind = require "setKind"
Tracer = require "tracer"
isType = require "isType"
define = require "define"
steal = require "steal"
Kind = require "Kind"
Void = require "Void"

hidden = Property { enumerable: no }

# Created for every instance of 'Component.Type'
# Created for every non-delegated subclass of 'Component'
module.exports =
ElementType = NamedFunction "ElementType", (componentType, initProps) ->

  assertType componentType, Kind(Function)
  assertType initProps, [ Function, Void ]

  if not initProps
    initProps = emptyFunction.thatReturnsArgument

  self = (props) ->
    props = {} if not props
    assertType props, Object, "props"
    applyMixins props
    key = stealKey props
    element = {}
    defineHiddenProperties element
    element.key = key if key isnt null
    element.type = componentType
    element.props = initProps props
    return element

  self.componentType = componentType

  setType self, ElementType

setKind ElementType, Function

#
# Helpers
#

define ElementType.prototype,

  propTypes: get: ->
    @componentType.propTypes

applyMixins = (props) ->
  return if not props.mixins
  mixins = steal props, "mixins"
  assertType mixins, Array, "props.mixins"
  for mixin in mixins
    for key, value of mixin
      continue if props[key] isnt undefined
      props[key] = value
  return

stealKey = (props) ->
  key = steal props, "key", null
  return key if key is null
  return key if isType key, String
  return key + ""

hiddenProperties =
  $$typeof: -> ReactElement.type
  _owner: -> ReactCurrentOwner.current
  _store: -> validated: no

defineHiddenProperties = (element) ->
  for key, getValue of hiddenProperties
    hidden.define element, key, getValue()
  return if not isDev
  hidden.define element, "_trace", Tracer "ReactElement()"
