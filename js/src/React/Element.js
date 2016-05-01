var Element, ReactElement, Validator, throwFailure;

throwFailure = require("failure").throwFailure;

Validator = require("type-utils").Validator;

ReactElement = require("ReactElement");

module.exports = Element = Validator("Element", {
  validate: function(value, key) {
    if (ReactElement.isValidElement(value)) {
      return true;
    }
    return {
      key: key,
      value: value,
      type: Element
    };
  },
  fail: function(values) {
    var error;
    if (values.key) {
      error = TypeError("'" + values.key + "' must be a ReactElement!");
    } else {
      error = TypeError("Expected a ReactElement.");
    }
    return throwFailure(error, values);
  }
});

//# sourceMappingURL=../../../map/src/React/Element.map
