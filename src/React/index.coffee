
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
    NativeComponent render

  ImageView: lazy: ->
    render = require "Image"
    NativeComponent render

  TextView: lazy: ->
    render = require "Text"
    NativeComponent render

  TextInput: lazy: ->
    render = require "TextInput"
    NativeComponent render

  WebView: lazy: ->
    render = require "WebView"
    NativeComponent render

  StaticRenderer: lazy: ->
    StaticRenderer = require "StaticRenderer"
    StaticRenderer.displayName = "StaticRenderer"
    require("ReactElement").createFactory StaticRenderer

  InteractionManager: lazy: ->
    require "InteractionManager"
