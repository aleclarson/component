var NativeComponent, OneOf, Style, TextInput;

OneOf = require("OneOf");

NativeComponent = require("../native/NativeComponent");

Style = require("../validators/Style");

TextInput = NativeComponent("TextInput", {
  render: require("TextInput"),
  propTypes: {
    autoCapitalize: OneOf(["characters", "words", "sentences", "none"]),
    autoCorrect: Boolean,
    autoFocus: Boolean,
    blurOnSubmit: Boolean,
    defaultValue: String,
    editable: Boolean,
    maxLength: Number,
    multiline: Boolean,
    onBlur: Function,
    onChange: Function,
    onContentSizeChange: Function,
    onEndEditing: Function,
    onFocus: Function,
    onLayout: Function,
    onSelectionChange: Function,
    onSubmitEditing: Function,
    placeholder: String,
    placeholderTextColor: String,
    secureTextEntry: Boolean,
    selectTextOnFocus: Boolean,
    selectionColor: String,
    style: Style
  }
});

module.exports = TextInput;

//# sourceMappingURL=map/TextInput.map
