
Typle = require "Typle"
Shape = require "Shape"
OneOf = require "OneOf"

NativeComponent = require "../native/NativeComponent"
Style = require "../validators/Style"

RemoteImageSource = Shape "RemoteImageSource", { uri: String }

ImageSource = Typle [ Number, RemoteImageSource ]

ImageResizeMode = OneOf "ImageResizeMode", [
  "cover"
  "contain"
  "stretch"
  "center"
]

EdgeInsetsType = Shape "EdgeInsetsType", {
  top: Number.Maybe
  left: Number.Maybe
  bottom: Number.Maybe
  right: Number.Maybe
}

ImageView = NativeComponent "ImageView",

  render: require "Image"

  propTypes:
    style: Style
    source: ImageSource.isRequired
    defaultSource: ImageSource
    resizeMode: ImageResizeMode
    capInsets: EdgeInsetsType
    onLayout: Function
    onLoadStart: Function
    onProgress: Function
    onError: Function
    onLoad: Function
    onLoadEnd: Function
    testID: String

module.exports = ImageView
