
{Style} = require "react-validators"

TextInput = require "TextInput"
React = require "react"
OneOf = require "OneOf"
steal = require "steal"
sync = require "sync"

NativeComponent = require "../NativeComponent"

type = NativeComponent "TextInput"

type.render (props) ->
  React.createElement TextInput, props

type.defineProps
  value: String
  defaultValue: String
  style: Style
  autoCapitalize: OneOf ["characters", "words", "sentences", "none"]
  autoCorrect: Boolean
  autoFocus: Boolean
  blurOnSubmit: Boolean
  editable: Boolean
  # keyboardType: OneOf []
  maxLength: Number
  maxLineCount: Number
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

type.defineMethods do ->
  keys = [
    "focus"
    "blur"
  ]
  sync.reduce keys, {}, (methods, key) ->
    methods[key] = ->
      @_child[key].apply @_child, arguments
    return methods

module.exports = type.build()
