
{ assert, assertType } = require "type-utils"

define = require "define"
Type = require "Type"

type = Type "StyleMap"

type.initInstance (inherited) ->

  return unless inherited

  assertType inherited, StyleMap

  for key, value of inherited._constantValues
    @_constantValues[key] = value

  for key, value of inherited._computedValues
    @_computedValues[key] = value

type.defineValues

  _constantValues: -> Object.create null

  _computedValues: -> Object.create null

type.defineStatics

  _presets: Object.create null

  addPreset: (presetName, style) ->
    assertType style, Object
    StyleMap._presets[presetName] = style
    return

type.defineMethods

  # Creates the interface used by each instance.
  bind: (context) ->

    self = this
    styles = Object.create null

    computedNames = Object.keys @_computedValues
    computedNames.forEach (styleName) ->
      define styles, styleName,
        value: -> self._compute styleName, context, arguments
        frozen: yes

    constantNames = Object.keys @_constantValues
    constantNames.forEach (styleName) ->
      return if self._computedValues[styleName]
      define styles, styleName,
        get: -> self._constantValues[styleName]
        frozen: yes

    return styles

  define: (styles) ->

    for styleName, style of styles

      if style.presets

        values = @_constantValues[styleName] ?= Object.create null

        for presetName in style.presets
          @_applyPreset presetName, values

        delete style.presets

      for key, value of style

        if value instanceof Function
          values = @_computedValues[styleName] ?= Object.create null
          values[key] = value

        else
          assert value isnt undefined, "Invalid style value: '#{styleName}.#{key}'"
          values = @_constantValues[styleName] ?= Object.create null
          values[key] = value

    return

  override: (styles) ->

    for styleName, style of styles

      assert @_constantValues[styleName] or @_computedValues[styleName],
        reason: "Could not find style to override: '#{styleName}'"

      @_constantValues[styleName] = constantValues = Object.create null
      @_computedValues[styleName] = computedValues = Object.create null

      if style.presets

        for presetName in style.presets
          @_applyPreset presetName, constantValues

        delete style.presets

      for key, value of style

        if value instanceof Function
          computedValues[key] = value

        else
          assert value isnt undefined, "Invalid style value: '#{styleName}.#{key}'"
          constantValues[key] = value

    return

  _applyPreset: (presetName, style) ->

    preset = StyleMap._presets[presetName]

    assert preset, "Invalid style preset: '#{presetName}'"

    for key, value of preset
      assert value isnt undefined, "Invalid style value: '#{presetName}.#{key}'"
      style[key] = value

    return

  _compute: (styleName, context, args) ->

    style = {}

    for key, value of @_computedValues[styleName]
      style[key] = value.apply context, args

    constantValues = @_constantValues[styleName]
    if constantValues
      for key, value of constantValues
        style[key] = value

    return style

module.exports = StyleMap = type.build()
