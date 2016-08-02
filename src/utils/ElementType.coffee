
require "isDev"

{ hidden } = require "Property"

ReactCurrentOwner = require "ReactCurrentOwner"
NamedFunction = require "NamedFunction"
emptyFunction = require "emptyFunction"
ReactElement = require "ReactElement"
assertType = require "assertType"
wrapValue = require "wrapValue"
setType = require "setType"
setKind = require "setKind"
Tracer = require "tracer"
isType = require "isType"
define = require "define"
steal = require "steal"
Kind = require "Kind"
Void = require "Void"

# Created for every instance of 'Component.Type'
# Created for every non-delegated subclass of 'Component'
module.exports =
ElementType = NamedFunction "ElementType", (componentType, initProps) ->

  assertType componentType, Kind(Function)
  assertType initProps, [ Function, Void ]

  if not initProps
    initProps = emptyFunction.thatReturnsArgument

  self = (props, children) ->

    props = {} if not props
    assertType props, Object, "props"

    if children
      props.children = children

    elementKey = stealKeyFromProps props
    applyMixinsToProps props

    element =
      key: elementKey
      type: componentType
      props: initProps props

    setInternals element,
      $$typeof: ReactElement.type
      _owner: ReactCurrentOwner.current
      _store: { validated: no }
      _trace: isDev and Tracer "ReactElement()"

    return element

  self.componentType = componentType

  setType self, ElementType

setKind ElementType, Function

#
# Helpers
#

define ElementType.prototype, "propTypes",
  get: -> @componentType.propTypes

setInternals = (obj, values) ->
  config = {}
  for key, value of values
    config.value = value
    hidden.define obj, key, config
  return

applyMixinsToProps = (props) ->
  return if not props.mixins
  mixins = steal props, "mixins"
  assertType mixins, Array, "props.mixins"
  for mixin in mixins
    for key, value of mixin
      continue if props[key] isnt undefined
      props[key] = value
  return

stealKeyFromProps = (props) ->
  key = steal props, "key"
  return if key is undefined
  return key if isType key, String
  return key + ""
