
OneOf = require "OneOf"

NativeComponent = require "../native/NativeComponent"
Style = require "../validators/Style"

TextInput = NativeComponent "TextInput",

  render: require "TextInput"

  propTypes:
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
    style: Style
    # TODO: Add `android` and `ios` specific props?

  methods: [
    "focus"
    "blur"
  ]

module.exports = TextInput
