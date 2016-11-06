
{AnimatedValue} = require "Animated"

React = require "react"
Image = require "Image"
Shape = require "Shape"
OneOf = require "OneOf"

AnimatedComponent = require "../AnimatedComponent"
Style = require "../validators/Style"

ImageResizeMode = OneOf "ImageResizeMode", "cover contain stretch center"
EdgeInsetsType = Shape "EdgeInsetsType", {top: Number.Maybe, left: Number.Maybe, bottom: Number.Maybe, right: Number.Maybe}

type = AnimatedComponent "ImageView"

type.render (props) ->
  React.createElement Image, props

type.defineProps
  style: Style
  source: Object.isRequired
  defaultSource: Object
  resizeMode: ImageResizeMode
  capInsets: EdgeInsetsType
  onLayout: Function
  onLoadStart: Function
  onProgress: Function
  onError: Function
  onLoad: Function
  onLoadEnd: Function
  testID: String

type.defineValues ->
  source: @props.source

type.defineListeners ->
  if @source instanceof AnimatedValue
    @source.didSet => @forceUpdate()

module.exports = type.build()
