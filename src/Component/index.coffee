
require "isDev"

ReactCurrentOwner = require "ReactCurrentOwner"
NamedFunction = require "NamedFunction"
ReactElement = require "ReactElement"
assertType = require "assertType"
Property = require "Property"
setKind = require "setKind"
setType = require "setType"
Tracer = require "tracer"
isType = require "isType"
define = require "define"
Type = require "Type"
hook = require "hook"

Builder = require "./Builder"

module.exports =
Component = NamedFunction "Component", (name) ->
  self = Builder name
  hook self, "build", build
  return self

setKind Component, Function

define Component,

  Type: lazy: ->
    require "./Type"

  StyleMap: lazy: ->
    require "./StyleMap"

build = (orig) ->
  type = orig.call this
  throw Error "'type' must be defined!" if not isType type, Function.Kind
  factory = createFactory type
  setType factory, Component
  factory.type = type
  return factory

createFactory = (type) -> (props) ->

  # NOTE: Avoid using if possible!
  if props.mixins
    mixins = steal props, "mixins"
    assertType mixins, Array, "props.mixins"
    for mixin in props.mixin
      for key, value of mixin
        continue if props[key] isnt undefined
        props[key] = value

  key = null
  if props.key?
    key = steal props, "key"
    key = "" + key if not isType key, String

  element = { type, props, key }

  prop = Property { enumerable: no }
  for key, getValue of elementProps
    prop.define element, key, getValue()

  if isDev
    prop.define element, "_trace", Tracer "ReactElement()"

  return element

elementProps =
  $$typeof: -> ReactElement.type
  _owner: -> ReactCurrentOwner.current
  _store: -> { validated: no }
