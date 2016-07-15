
OneOf = require "OneOf"
Void = require "Void"

NativeComponent = require "../Native/Component"
Children = require "./Children"
Style = require "./Style"

PointerEventType = OneOf "PointerEventType", [ "box-none", "none", "box-only", "auto" ]

module.exports = NativeComponent "View",

  render: require "View"

  propTypes:
    style: Style
    children: Children
    pointerEvents: [ PointerEventType, Void ]
    testID: String.Maybe
    onLayout: Function.Maybe
    onResponderReject: Function.Maybe
    onResponderGrant: Function.Maybe
    onResponderMove: Function.Maybe
    onResponderRelease: Function.Maybe
    onResponderTerminate: Function.Maybe
    onResponderTerminationRequest: Function.Maybe
    onStartShouldSetResponder: Function.Maybe
    onStartShouldSetResponderCapture: Function.Maybe
    onMoveShouldSetResponder: Function.Maybe
    onMoveShouldSetResponderCapture: Function.Maybe
    needsOffscreenAlphaCompositing: Boolean.Maybe
    renderToHardwareTextureAndroid: Boolean.Maybe
    removeClippedSubviews: Boolean.Maybe
    shouldRasterizeIOS: Boolean.Maybe
    collapsable: Boolean.Maybe
