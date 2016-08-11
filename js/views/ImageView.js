var EdgeInsetsType, ImageResizeMode, ImageSource, NativeComponent, OneOf, RemoteImageSource, Shape, Style, Void;

Shape = require("Shape");

OneOf = require("OneOf");

Void = require("Void");

NativeComponent = require("../native/NativeComponent");

Style = require("../validators/Style");

RemoteImageSource = Shape("RemoteImageSource", {
  uri: String
});

ImageSource = [Number, RemoteImageSource];

ImageResizeMode = OneOf("ImageResizeMode", ["cover", "contain", "stretch"]);

EdgeInsetsType = Shape("EdgeInsetsType", {
  top: Number.Maybe,
  left: Number.Maybe,
  bottom: Number.Maybe,
  right: Number.Maybe
});

module.exports = NativeComponent("ImageView", {
  render: require("ImageView"),
  propTypes: {
    style: Style,
    source: ImageSource,
    defaultSource: [ImageSource, Void],
    resizeMode: [ImageResizeMode, Void],
    capInsets: [EdgeInsetsType, Void],
    onLayout: Function.Maybe,
    onLoadStart: Function.Maybe,
    onProgress: Function.Maybe,
    onError: Function.Maybe,
    onLoad: Function.Maybe,
    onLoadEnd: Function.Maybe,
    testID: String.Maybe
  }
});

//# sourceMappingURL=map/ImageView.map
