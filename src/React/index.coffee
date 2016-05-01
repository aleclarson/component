
NativeComponent = require "../Native/Component"

module.exports =

  Element: lazy: ->
    require "./Element"

  Children: lazy: ->
    require "./Children"

  Style: lazy: ->
    require "./Style"

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

  InteractionManager: lazy: ->
    require "InteractionManager"
