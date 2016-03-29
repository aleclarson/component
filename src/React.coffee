
NativeComponent = require "./NativeComponent"

module.exports =

  View: lazy: ->
    NativeComponent "View", require "View"

  ImageView: lazy: ->
    NativeComponent "ImageView", require "Image"

  TextView: lazy: ->
    NativeComponent "TextView", require "Text"

  TextInput: lazy: ->
    NativeComponent "TextInput", require "TextInput"

  WebView: lazy: ->
    NativeComponent "WebView", require "WebView"

  StaticRenderer: lazy: ->
    StaticRenderer = require "StaticRenderer"
    StaticRenderer.displayName = "StaticRenderer"
    (require "ReactElement").createFactory StaticRenderer

  Element: lazy: ->
    require "./Element"

  Children: lazy: ->
    require "./Children"

  Style: lazy: ->
    require "./Style"

  InteractionManager: lazy: ->
    require "InteractionManager"
