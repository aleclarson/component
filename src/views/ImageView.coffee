
{AnimatedValue} = require "Animated"
{Style} = require "react-validators"

React = require "react"
Image = require "Image"
Shape = require "Shape"
OneOf = require "OneOf"
Null = require "Null"

NativeComponent = require "../NativeComponent"

ImageResizeMode = OneOf "ImageResizeMode", "cover contain stretch center"
EdgeInsetsType = Shape "EdgeInsetsType", {top: Number.Maybe, left: Number.Maybe, bottom: Number.Maybe, right: Number.Maybe}

type = NativeComponent "ImageView"

type.render (props) ->
  React.createElement Image, props

type.defineProps
  style: Style
  source: Object.or Null
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
