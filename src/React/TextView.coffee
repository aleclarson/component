
NativeComponent = require "../Native/Component"
Style = require "./Style"

module.exports = NativeComponent "TextView",

  render: require "Text"

  propTypes:
    numberOfLines: Number.Maybe
    onLayout: Function.Maybe
    onPress: Function.Maybe
    suppressHighlighting: Boolean.Maybe
    style: Style
    testID: String.Maybe
    allowFontScaling: Boolean.Maybe
