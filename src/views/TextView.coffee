
{AnimatedValue} = require "Animated"
{Style} = require "react-validators"

React = require "react"
steal = require "steal"
Text = require "Text"

NativeComponent = require "../NativeComponent"

type = NativeComponent "TextView"

type.render (props) ->
  React.createElement Text, props, @text

type.defineProps
  text: String.isRequired
  style: Style
  onPress: Function
  onLayout: Function
  numberOfLines: Number
  allowFontScaling: Boolean
  suppressHighlighting: Boolean
  testID: String

type.defineValues (props) ->
  _text: steal props, "text"

type.defineListeners ->
  if @_text instanceof AnimatedValue
    @_text.didSet => @forceUpdate()

type.defineGetters

  text: ->
    if text = @_text
      if text instanceof AnimatedValue
      then text.get()
      else text
    else null

module.exports = type.build()
