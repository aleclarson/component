
NativeComponent = require "../Native/Component"

module.exports =

  Element: lazy: ->
    require "./Element"

  Children: lazy: ->
    require "./Children"

  Style: lazy: ->
    require "./Style"

  View: lazy: ->
    render = require "View"
    NativeComponent "View", render

  ImageView: lazy: ->
    render = require "Image"
    NativeComponent "ImageView", render

  TextView: lazy: ->
    render = require "Text"
    NativeComponent "TextView", render

  TextInput: lazy: ->
    render = require "TextInput"
    NativeComponent "TextInput", render

  WebView: lazy: ->
    render = require "WebView"
    NativeComponent "WebView", render

  StaticRenderer: lazy: ->
    StaticRenderer = require "StaticRenderer"
    StaticRenderer.displayName = "StaticRenderer"
    require("ReactElement").createFactory StaticRenderer

  InteractionManager: lazy: ->
    require "InteractionManager"
