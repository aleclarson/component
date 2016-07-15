
NativeComponent = require "../Native/Component"

module.exports =

  Element: lazy: ->
    require "./Element"

  Children: lazy: ->
    require "./Children"

  Style: lazy: ->
    require "./Style"

  View: lazy: ->
    require "./View"

  ImageView: lazy: ->
    require "./ImageView"

  TextView: lazy: ->
    require "./TextView"

  # TextInput: lazy: ->
  #   render = require "TextInput"
  #   NativeComponent "TextInput", render
  #
  # WebView: lazy: ->
  #   render = require "WebView"
  #   NativeComponent "WebView", render

  StaticRenderer: lazy: ->
    StaticRenderer = require "StaticRenderer"
    StaticRenderer.displayName = "StaticRenderer"
    require("ReactElement").createFactory StaticRenderer

  InteractionManager: lazy: ->
    require "InteractionManager"
