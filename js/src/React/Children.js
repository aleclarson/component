var Children, ReactElement, Validator, throwFailure;

throwFailure = require("failure").throwFailure;

Validator = require("type-utils").Validator;

ReactElement = require("ReactElement");

module.exports = Children = Validator("Children", {
  validate: function(value, key) {
    if (value === void 0) {
      return true;
    }
    if (ReactElement.isValidElement(value)) {
      return true;
    }
    if (Array.isArray(value)) {
      return true;
    }
    return {
      key: key,
      value: value,
      type: Children
    };
  },
  fail: function(values) {
    var error;
    if (values.key) {
      error = TypeError("'" + values.key + "' must be an Array or ReactElement!");
    } else {
      error = TypeError("Expected an Array or ReactElement.");
    }
    return throwFailure(error, values);
  }
});

//# sourceMappingURL=../../../map/src/React/Children.map
