var EdgeInsetsType, ImageResizeMode, ImageSource, NativeComponent, OneOf, RemoteImageSource, Shape, Style;

Shape = require("Shape");

OneOf = require("OneOf");

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
    source: ImageSource.isRequired,
    defaultSource: ImageSource,
    resizeMode: ImageResizeMode,
    capInsets: EdgeInsetsType,
    onLayout: Function,
    onLoadStart: Function,
    onProgress: Function,
    onError: Function,
    onLoad: Function,
    onLoadEnd: Function,
    testID: String
  }
});

//# sourceMappingURL=map/ImageView.map
