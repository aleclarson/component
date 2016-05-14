var Element, Validator, Void, throwFailure, validTypes;

throwFailure = require("failure").throwFailure;

Validator = require("Validator");

Void = require("Void");

Element = require("./Element");

validTypes = [Element, Array, Void];

module.exports = Validator("ReactChildren", {
  test: function(value) {
    return isType(value, validTypes);
  },
  assert: function(value, key) {
    if (this.test(value)) {
      return;
    }
    return wrongType(validTypes, key);
  }
});

//# sourceMappingURL=../../../map/src/React/Children.map
