
require "isDev"

{frozen} = require "Property"

cloneObject = require "cloneObject"
emptyObject = require "emptyObject"
PureObject = require "PureObject"
assertType = require "assertType"
fillValue = require "fillValue"
inArray = require "in-array"
isType = require "isType"
Type = require "Type"
sync = require "sync"
has = require "has"

type = Type "StyleMap"

type.defineValues

  _styleNames: PureObject.create

  _constantStyles: PureObject.create

  _computedStyles: PureObject.create

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
            @_getValues styleName, contextStyles, context, arguments
        return style

    sync.keys @_styleNames, (styleName) =>
      frozen.define styles, styleName, value: =>
        @_getValues styleName, contextStyles, context, arguments

    return styles

  define: (styles) ->

    assertType styles, Object

    for styleName, style of styles

      if @_styleNames[styleName]
        throw Error "Cannot define an existing style: '#{styleName}'"

      @_styleNames[styleName] = yes
      @_parseStyle styleName, style or emptyObject

    return

  append: (styles) ->

    assertType styles, Object

    for styleName, style of styles

      if not @_styleNames[styleName]
        throw Error "Cannot append to undefined style: '#{styleName}'"

      @_parseStyle styleName, style or emptyObject

    return

  override: (styles) ->

    assertType styles, Object

    constantStyles = @_constantStyles
    computedStyles = @_computedStyles

    for styleName, style of styles

      unless constantStyles[styleName] or computedStyles[styleName]
        throw Error "Cannot override an undefined style: '#{styleName}'"

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
      styles[styleName] = @_getValues styleName, contextStyles[styleName], context, args
    return styles

  _parseStyle: (styleName, style) ->

    assertType styleName, String
    assertType style, Object

    constantStyle = fillValue @_constantStyles, styleName, PureObject.create
    computedStyle = fillValue @_computedStyles, styleName, PureObject.create

    for key, value of style

      # Parse computed styles.
      if value instanceof Function
        computedStyle[key] = parseTransform value, key
        delete constantStyle[key] if has constantStyle, key

      # Parse constant styles that use presets.
      else if StyleMap._presets[key]
        sync.each callPreset(key, value), (value, key) ->
          if not value?
            throw TypeError "Invalid style value for key: '#{styleName}.#{key}'"
          constantStyle[key] = value
          delete computedStyle[key] if has computedStyle, key

      else if not value?
        throw TypeError "Invalid style value for key: '#{styleName}.#{key}'"

      # Parse constant styles.
      else
        constantStyle[key] = parseTransform value, key
        delete computedStyle[key] if has computedStyle, key

    return

  _getValues: (styleName, contextStyles, context, args) ->

    values = transform: []

    @_applyConstantStyle values, @_constantStyles[styleName]
    @_applyComputedStyle values, @_computedStyles[styleName], context, args
    @_applyContextStyle values, contextStyles[styleName] if contextStyles

    # TODO: It might not hurt to keep an empty 'transform'.
    delete values.transform if not values.transform.length
    return values

  _applyConstantStyle: (values, style) ->
    return if not style
    for key, { value, isTransform } of style
      if isTransform
        values.transform.push assign {}, key, value
      else values[key] = value
    return

  _applyComputedStyle: (values, style, context, args) ->
    return if not style
    for key, { value, isTransform } of style
      value = value.apply context, args
      continue if value is undefined
      if StyleMap._presets[key]
        sync.each callPreset(key, value), ({ value, isTransform }, key) ->
          if not value?
            throw TypeError "Invalid style value for key: '#{key}'"
          if isTransform
            values.transform.push assign {}, key, value
          else values[key] = value
      else if isTransform
        values.transform.push assign {}, key, value
      else values[key] = value
    return

  _applyContextStyle: (values, style) ->
    for key, { value, isTransform } of style
      if isTransform
        values.transform.push assign {}, key, value
      else values[key] = value
    return

type.defineStatics

  _presets: Object.create null

  addPreset: (presetName, style) ->

    assertType presetName, String
    assertType style, Object.or Function

    if isType style, Object
      style = sync.map style, parseTransform
      preset = -> style

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

assign = (obj, key, value) ->
  obj[key] = value
  return obj

isTransformKey = do ->
  keys = [ "scale", "translateX", "translateY", "rotate" ]
  return (key) -> inArray keys, key

parseTransform = (value, key) ->
  { value, isTransform: isTransformKey key }

callPreset = (presetName, presetArg) ->
  style = StyleMap._presets[presetName] presetArg
  assertType style, Object
  return style

#
# Initialize default presets
#

presets = require "./StylePresets"
StyleMap.addPresets presets
