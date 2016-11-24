
require "isDev"

{frozen} = require "Property"

cloneObject = require "cloneObject"
emptyObject = require "emptyObject"
PureObject = require "PureObject"
assertType = require "assertType"
Type = require "Type"
sync = require "sync"
has = require "has"

StyleTransform = require "./StyleTransform"
StylePresets = require "./StylePresets"

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
        style = sync.map style, StyleTransform.parse
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

    constantStyle = @_constantStyles[styleName] ?= Object.create null
    computedStyle = @_computedStyles[styleName] ?= Object.create null

    for key, value of style

      # Parse computed styles.
      if value instanceof Function
        computedStyle[key] = StyleTransform.parse value, key
        delete constantStyle[key] if has constantStyle, key

      # Parse constant styles that use presets.
      else if StylePresets.has key
        presetStyle = StylePresets.call key, value
        sync.each presetStyle, (value, key) ->
          constantStyle[key] = StyleTransform.parse value, key
          delete computedStyle[key] if has computedStyle, key

      # Parse constant styles.
      else
        constantStyle[key] = StyleTransform.parse value, key
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
      continue if not value?
      if isTransform
      then addTransform values.transform, key, value
      else values[key] = value
    return

  _applyComputedStyle: (values, style, context, args) ->
    return if not style
    for key, { value, isTransform } of style

      value = value.apply context, args
      continue if not value?

      if StylePresets.has key
        presetStyle = StylePresets.call key, value
        sync.each presetStyle, (value, key) ->
          return if not value?
          if StyleTransform.test value, key
          then addTransform values.transform, key, value
          else values[key] = value
        continue

      if isTransform
      then addTransform values.transform, key, value
      else values[key] = value
    return

  _applyContextStyle: (values, style) ->
    for key, { value, isTransform } of style
      if isTransform
      then addTransform values.transform, key, value
      else values[key] = value
    return

module.exports = StyleMap = type.build()

#
# Helpers
#

addTransform = (array, key, value) ->
  obj = {}
  obj[key] = value
  array.push obj
  return
