
TextInput = require "TextInput"
React = require "react"
OneOf = require "OneOf"
steal = require "steal"

AnimatedComponent = require "../AnimatedComponent"
Style = require "../validators/Style"

type = AnimatedComponent "TextInput"

type.render (props) ->
  React.createElement TextInput, props

type.defineProps
  style: Style
  autoCapitalize: OneOf ["characters", "words", "sentences", "none"]
  autoCorrect: Boolean
  autoFocus: Boolean
  blurOnSubmit: Boolean
  defaultValue: String
  editable: Boolean
  # keyboardType: OneOf []
  maxLength: Number
  multiline: Boolean
  onBlur: Function
  onChange: Function
  onContentSizeChange: Function
  onEndEditing: Function
  onFocus: Function
  onLayout: Function
  onSelectionChange: Function
  onSubmitEditing: Function
  placeholder: String
  placeholderTextColor: String
  # returnKeyType: OneOf []
  secureTextEntry: Boolean
  selectTextOnFocus: Boolean
  selectionColor: String
  # TODO: Add `android` and `ios` specific props?

type.defineMethods

  focus: ->
    @_child.focus()

  blur: ->
    @_child.blur()

module.exports = type.build()
