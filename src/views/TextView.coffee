
NativeComponent = require "../native/NativeComponent"
Style = require "../validators/Style"

module.exports = NativeComponent "TextView",

  render: require "Text"

  propTypes:
    style: Style
    onPress: Function
    onLayout: Function
    numberOfLines: Number
    allowFontScaling: Boolean
    suppressHighlighting: Boolean
    testID: String
