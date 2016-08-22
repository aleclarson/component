var EdgeInsetsType, ImageResizeMode, ImageSource, ImageView, NativeComponent, OneOf, RemoteImageSource, Shape, Style;

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

ImageView = NativeComponent("ImageView", {
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

module.exports = ImageView;

//# sourceMappingURL=map/ImageView.map
