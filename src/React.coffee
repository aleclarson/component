
reportFailure = require "report-failure"
LazyVar = require "lazy-var"

NativeComponent = require "./NativeComponent"

module.exports =

  View: LazyVar ->
    NativeComponent "View", require "View"

  ImageView: LazyVar ->
    NativeComponent "ImageView", require "Image"

  TextView: LazyVar ->
    NativeComponent "TextView", require "Text"

  TextInput: LazyVar ->
    NativeComponent "TextInput", require "TextInput"

  ScrollView: LazyVar ->
    NativeComponent "ScrollView", require "ScrollView"

  ListView: LazyVar ->
    ListView = NativeComponent "ListView", require "ListView"
    ListView.DataSource = require "ListViewDataSource"
    ListView

  WebView: LazyVar ->
    NativeComponent "WebView", require "WebView"

  Touchable: LazyVar ->
    Touchable = require "TouchableWithoutFeedback"
    Touchable.displayName = "Touchable"
    ReactElement = require "ReactElement"
    ReactElement.createFactory Touchable

  StaticRenderer: LazyVar ->
    ReactElement = require "ReactElement"
    ReactElement.createFactory require "StaticRenderer"

  PanResponder: LazyVar ->
    require "PanResponder"

  Easing: LazyVar ->
    require "Easing"

  Interpolation: LazyVar ->
    require "Interpolation"

  NativeModules: LazyVar ->
    require "NativeModules"

  Children: LazyVar ->
    require "./Children"

  Style: LazyVar ->
    require "./Style"
