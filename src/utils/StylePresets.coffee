
assertTypes = require "assertTypes"
assertType = require "assertType"
hexToRgb = require "hex-rgb"
sync = require "sync"

propTypes =

  border:
    color: String
    width: Number
    opacity: Number.Maybe
    radius: Number.Maybe

styles =

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

# Static styles are hoisted out of their "style functions".
sync.each styles, (style, key) ->
  styles[key] = -> style

module.exports = Object.assign styles,

  border: (props) ->
    assertTypes props, propTypes.border

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
    assertType enabled, Boolean
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
    assertType enabled, Boolean
    if enabled
      flex: 1
      alignSelf: "stretch"
    else
      flex: null
      alignSelf: null

  size: (size) ->
    assertType size, Number
    width: size
    height: size

  diameter: (size) ->
    assertType size, Number
    width: size
    height: size
    borderRadius: size / 2

#
# Helpers
#

createRgbaColor = (color, alpha) ->
  rgb = hexToRgb(color).join ", "
  return "rgba(#{rgb}, #{alpha})"
