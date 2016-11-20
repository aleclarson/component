
{Style, Children} = require "react-validators"

React = require "react"
OneOf = require "OneOf"
Shape = require "Shape"
View = require "View"

NativeComponent = require "../NativeComponent"

PointerEvents = OneOf "PointerEvents", "auto none box-none box-only"
LayoutAttributes = Shape "LayoutAttributes", {top: Number, right: Number, bottom: Number, left: Number}

type = NativeComponent "View"

type.render (props) ->
  React.createElement View, props

type.defineProps
  style: Style
  children: Children
  pointerEvents: PointerEvents
  hitSlop: LayoutAttributes
  testID: String
  onLayout: Function
  onResponderReject: Function
  onResponderGrant: Function
  onResponderMove: Function
  onResponderRelease: Function
  onResponderTerminate: Function
  onResponderTerminationRequest: Function
  onStartShouldSetResponder: Function
  onStartShouldSetResponderCapture: Function
  onMoveShouldSetResponder: Function
  onMoveShouldSetResponderCapture: Function
  needsOffscreenAlphaCompositing: Boolean
  renderToHardwareTextureAndroid: Boolean
  removeClippedSubviews: Boolean
  shouldRasterizeIOS: Boolean
  collapsable: Boolean

module.exports = type.build()
