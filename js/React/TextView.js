var NativeComponent, Style;

NativeComponent = require("../Native/Component");

Style = require("./Style");

module.exports = NativeComponent("TextView", {
  render: require("Text"),
  propTypes: {
    style: Style,
    onPress: Function.Maybe,
    onLayout: Function.Maybe,
    numberOfLines: Number.Maybe,
    allowFontScaling: Boolean.Maybe,
    suppressHighlighting: Boolean.Maybe,
    testID: String.Maybe
  }
});

//# sourceMappingURL=map/TextView.map
