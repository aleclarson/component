var ReactElement, Validator, throwFailure, wrongType;

throwFailure = require("failure").throwFailure;

ReactElement = require("ReactElement");

Validator = require("Validator");

wrongType = require("wrongType");

module.exports = Validator("ReactElement", {
  test: function(value) {
    return ReactElement.isValidElement(value);
  },
  assert: function(value, key) {
    if (this.test(value)) {
      return;
    }
    return wrongType(this, key);
  }
});

//# sourceMappingURL=../../../map/src/React/Element.map
