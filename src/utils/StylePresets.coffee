
assertTypes = require "assertTypes"
assertType = require "assertType"
hexToRgb = require "hex-rgb"
isType = require "isType"
isDev = require "isDev"
Type = require "Type"
sync = require "sync"

type = Type "StylePresets"

type.defineValues ->

  _presets: Object.create null

type.defineMethods

  has: (key) ->
    @_presets[key] isnt undefined

  get: (key) ->
    @_presets[key]

  call: (key, arg1) ->
    isDev and assertType key, String
    style = @_presets[key] arg1
    if isDev and not isType style, Object
      throw TypeError "Style presets must return an object!"
    return style

  apply: (style, key, arg1) ->
    isDev and assertType style, Object
    Object.assign style, StylePresets.call key, arg1

  define: ->
    args = arguments
    isDev and assertType args[0], String.or Object
    if isType args[0], String
    then @_definePreset args[0], args[1]
    else @_definePresets args[0]

  _definePreset: (key, style) ->
    isDev and assertType style, Object.or Function

    if isDev and @_presets[key]
      throw Error "Style preset already exists: '#{key}'"

    @_presets[key] =
      if isType style, Object
      then -> style
      else style
    return

  _definePresets: (presets) ->
    for key, style of presets
      @_definePreset key, style
    return

module.exports = StylePresets = type.construct()

isDev and propTypes =

  border:
    color: String
    width: Number
    opacity: Number.Maybe
    radius: Number.Maybe

StylePresets.define

  clear:
    backgroundColor: "transparent"

  leftAlign:
    flex: 1
    flexDirection: "row"
    justifyContent: "flex-start"

  rightAlign:
    flex: 1
    flexDirection: "row"
    justifyContent: "flex-end"

  centerItems:
    alignItems: "center"
    justifyContent: "center"

  border: (props) ->
    isDev and assertTypes props, propTypes.border

    style =
      borderWidth: props.width
      borderColor:
        if props.opacity isnt undefined
        then createRgbaColor props.color, props.opacity
        else props.color

    if props.radius isnt undefined
      style.borderRadius = props.radius

    return style

  cover: (enabled) ->
    isDev and assertType enabled, Boolean
    if enabled
      position: "absolute"
      top: 0
      left: 0
      right: 0
      bottom: 0
    else
      position: null
      top: null
      left: null
      right: null
      bottom: null

  fill: (enabled) ->
    isDev and assertType enabled, Boolean
    if enabled
      flex: 1
      alignSelf: "stretch"
    else
      flex: null
      alignSelf: null

  size: (size) ->
    isDev and assertType size, Number
    width: size
    height: size

  diameter: (size) ->
    isDev and assertType size, Number
    width: size
    height: size
    borderRadius: size / 2

#
# Helpers
#

createRgbaColor = (color, alpha) ->
  rgb = hexToRgb(color).join ", "
  return "rgba(#{rgb}, #{alpha})"
