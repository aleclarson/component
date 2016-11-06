
{AnimatedValue} = require "Animated"

assertType = require "assertType"
isType = require "isType"
Shape = require "Shape"
isDev = require "isDev"
Type = require "Type"
has = require "has"

type = Type "PropValidator"

type.defineValues ->

  types: {}

  defaults: {}

  _names: []

  _required: {}

type.initInstance (props) ->
  props and @define props

type.defineMethods

  # Any pre-defined props are overwritten.
  define: (props) ->
    assertType props, Object
    for name, prop of props

      if 0 > @_names.indexOf name
        @_names.push name

      if not isType prop, Object
        @types[name] = prop
        continue

      if has prop, "default"
        @defaults[name] = prop.default

      continue if not prop.type
      @types[name] =
        if isType prop.type, Object
        then Shape prop.type
        else prop.type

      if prop.required
        @_required[name] = yes

    return

type.defineBoundMethods

  validate: (props) ->

    for name in @_names

      prop = props[name]
      if prop is undefined

        if @defaults[name] isnt undefined
          props[name] = prop = @defaults[name]

        else if not @_required[name]
          continue

      else if prop instanceof AnimatedValue
        prop = (animatedProp = prop).get()

      if isDev and propType = @types[name]
        assertType prop, propType, "props." + name

    return props

module.exports = type.build()
