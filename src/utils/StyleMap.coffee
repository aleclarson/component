
require "isDev"

isConstructor = require "isConstructor"
cloneObject = require "cloneObject"
emptyObject = require "emptyObject"
PureObject = require "PureObject"
assertType = require "assertType"
fillValue = require "fillValue"
Property = require "Property"
inArray = require "in-array"
assert = require "assert"
Type = require "Type"
sync = require "sync"
has = require "has"
run = require "run"

{ frozen } = Property

type = Type "StyleMap"

type.defineValues

  _styleNames: -> Object.create null

  _constantStyles: -> Object.create null

  _computedStyles: -> Object.create null

type.initInstance (inherited) ->

  return unless inherited

  assertType inherited, StyleMap

  sync.keys inherited._styleNames, (styleName) =>

    @_styleNames[styleName] = yes

    style = inherited._constantStyles[styleName]
    @_constantStyles[styleName] = cloneObject style if style

    style = inherited._computedStyles[styleName]
    @_computedStyles[styleName] = cloneObject style if style

type.defineMethods

  bind: (context) ->

    styleNames = @_styleNames
    styles = Object.create null

    { props } = context
    if props and props.styles
      contextStyles = sync.map props.styles, (style, styleName) =>
        style = sync.map style, parseTransform
        if not @_styleNames[styleName]
          frozen.define styles, styleName, value: =>
            @_buildStyle styleName, contextStyles, context, arguments
        return style

    sync.keys @_styleNames, (styleName) =>
      frozen.define styles, styleName, value: =>
        @_buildStyle styleName, contextStyles, context, arguments

    return styles

  define: (styles) ->
    assertType styles, Object
    for styleName, style of styles
      assert not @_styleNames[styleName], "Cannot define an existing style: '#{styleName}'"
      @_styleNames[styleName] = yes
      @_parseStyle styleName, style or emptyObject
    return

  append: (styles) ->
    assertType styles, Object
    for styleName, style of styles
      assert @_styleNames[styleName], "Cannot append to undefined style: '#{styleName}'"
      @_parseStyle styleName, style or emptyObject
    return

  override: (styles) ->

    assertType styles, Object

    constantStyles = @_constantStyles
    computedStyles = @_computedStyles

    for styleName, style of styles

      assert constantStyles[styleName] or computedStyles[styleName],
        reason: "Cannot override an undefined style: '#{styleName}'"

      delete constantStyles[styleName]
      delete computedStyles[styleName]

      continue if not style
      @_parseStyle styleName, style

    return

  build: (contextStyles = {}, context, args) ->
    assertType contextStyles, Object
    assertType args, Array.Maybe
    styles = {}
    sync.keys @_styleNames, (styleName) =>
      styles[styleName] = @_buildStyle styleName, contextStyles[styleName], context, args
    return styles

  _parseStyle: (styleName, style) ->

    assertType styleName, String
    assertType style, Object

    constantValues = fillValue @_constantStyles, styleName, PureObject.create
    computedValues = fillValue @_computedStyles, styleName, PureObject.create

    for key, value of style

      if StyleMap._presets[key]
        applyPreset key, value, constantValues
        continue

      if value instanceof Function
        computedValues[key] = parseTransform value, key
        delete constantValues[key] if has constantValues, key
      else
        assert value isnt undefined, "Invalid style value: '#{styleName}.#{key}'"
        constantValues[key] = parseTransform value, key
        delete computedValues[key] if has computedValues, key

    return

  _buildStyle: (styleName, contextStyles, context, args) ->

    style =
      transform: []

    @_buildConstantStyle style, @_constantStyles[styleName]
    @_buildComputedStyle style, @_computedStyles[styleName], context, args
    @_buildContextStyle style, contextStyles[styleName] if contextStyles

    # TODO: It might not hurt to keep an empty 'transform'.
    if not style.transform.length
      delete style.transform

    return style

  _buildConstantStyle: (style, values) ->
    return if not values
    for key, { value, isTransform } of values
      if not isTransform then style[key] = value
      else style.transform.push assign {}, key, value
    return

  _buildComputedStyle: (style, values, context, args) ->
    return if not values
    for key, { value, isTransform } of values
      value = value.apply context, args
      continue if value is undefined
      if not isTransform then style[key] = value
      else style.transform.push assign {}, key, value
    return

  _buildContextStyle: (style, values) ->
    for key, { value, isTransform } of values
      if not isTransform then style[key] = value
      else style.transform.push assign {}, key, value
    return

type.defineStatics

  _presets: Object.create null

  addPreset: (presetName, style) ->

    assertType presetName, String
    assertType style, [ Object, Function ]

    if isConstructor style, Object
      style = sync.map style, parseTransform
      preset = ->
        return style

    else
      preset = ->
        values = style.apply this, arguments
        return sync.map values, parseTransform

    StyleMap._presets[presetName] = preset
    return

  addPresets: (presets) ->
    for presetName, createStyle of presets
      @addPreset presetName, createStyle
    return

module.exports = StyleMap = type.build()

#
# Helpers
#

parseTransform = run ->
  keys = [ "scale", "translateX", "translateY", "rotate" ]
  return (value, key) ->
    result = { value }
    result.isTransform = yes if inArray keys, key
    return result

assign = (obj, key, value) ->
  obj[key] = value
  return obj

applyPreset = (presetName, presetArg, constantValues) ->
  createStyle = StyleMap._presets[presetName]
  style = createStyle presetArg
  assertType style, Object, "style"
  for key, value of style
    assert value isnt undefined, "Invalid style value: '#{presetName}.#{key}'"
    constantValues[key] = value
  return

#
# Initialize default presets
#

presets = require "./StylePresets"
StyleMap.addPresets presets
