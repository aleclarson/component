
OneOf = require "OneOf"

NativeComponent = require "../native/NativeComponent"
Children = require "../validators/Children"
Style = require "../validators/Style"

PointerEventType = OneOf "PointerEventType", [ "box-none", "none", "box-only", "auto" ]

View = NativeComponent "View",

  render: require "View"

  propTypes:
    style: Style
    children: Children
    pointerEvents: PointerEventType
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

module.exports = View
