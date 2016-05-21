
require "isDev"

cloneObject = require "cloneObject"
PureObject = require "PureObject"
assertType = require "assertType"
fillValue = require "fillValue"
Property = require "Property"
assert = require "assert"
Type = require "Type"
sync = require "sync"
has = require "has"

type = Type "StyleMap"

type.defineValues

  _styles: -> Object.create null

  _constantStyles: -> Object.create null

  _computedStyles: -> Object.create null

type.initInstance (inherited) ->

  return unless inherited

  assertType inherited, StyleMap

  sync.keys inherited._styles, (styleName) =>

    @_styles[styleName] = yes

    style = inherited._constantStyles[styleName]
    @_constantStyles[styleName] = cloneObject style if style

    style = inherited._computedStyles[styleName]
    @_computedStyles[styleName] = cloneObject style if style

type.defineMethods

  bind: (context) ->

    prop = Property { frozen: isDev }
    styles = Object.create null

    constantStyles = @_constantStyles
    computedStyles = @_computedStyles
    sync.keys @_styles, (styleName) =>
      prop.define styles, styleName, =>
        @_buildStyle styleName, context, arguments

    return styles

  define: (styles) ->
    for styleName, style of styles
      continue if not style
      @_styles[styleName] = yes
      @_parseStyle styleName, style
    return

  override: (styles) ->

    constantStyles = @_constantStyles
    computedStyles = @_computedStyles

    for styleName, style of styles

      assert constantStyles[styleName] or computedStyles[styleName],
        reason: "Could not find style to override: '#{styleName}'"

      delete constantStyles[styleName]
      delete computedStyles[styleName]

      continue if not style
      @_parseStyle styleName, style

    return

  _parseStyle: (styleName, style) ->

    assertType style, Object

    constantValues = fillValue @_constantStyles, styleName, PureObject.create
    computedValues = fillValue @_computedStyles, styleName, PureObject.create

    for key, value of style

      if StyleMap._presets[key]
        applyPreset key, value, constantValues
        continue

      if value instanceof Function
        computedValues[key] = value
        delete constantValues[key] if has constantValues, key
      else
        assert value isnt undefined, "Invalid style value: '#{styleName}.#{key}'"
        constantValues[key] = value
        delete computedValues[key] if has computedValues, key

    return

  _buildStyle: (styleName, context, args) ->

    style = {}

    constantValues = @_constantStyles[styleName]
    if constantValues
      for key, value of constantValues
        if TRANSFORMS[key]
          transform = [] if not transform
          transform.push pairKeyValue key, value
        else style[key] = value

    computedValues = @_computedStyles[styleName]
    if computedValues
      for key, value of computedValues
        value = value.apply context, args
        if TRANSFORMS[key]
          transform = [] if not transform
          transform.push pairKeyValue key, value
        else style[key] = value

    style.transform = transform if transform
    return style

type.defineStatics

  _presets: Object.create null

  addPreset: (presetName, createStyle) ->
    assertType presetName, String
    assertType createStyle, Function
    StyleMap._presets[presetName] = createStyle
    return

module.exports = StyleMap = type.build()

TRANSFORMS = { scale: 1, translateX: 1, translateY: 1, rotate: 1 }

applyPreset = (presetName, presetArg, constantValues) ->
  createStyle = StyleMap._presets[presetName]
  style = createStyle presetArg
  assertType style, Object, "style"
  for key, value of style
    assert value isnt undefined, "Invalid style value: '#{presetName}.#{key}'"
    constantValues[key] = value
  return

pairKeyValue = (key, value) ->
  pair = {}
  pair[key] = value
  return pair
