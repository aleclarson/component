var Element, Validator, isType, validTypes, wrongType;

Validator = require("Validator");

wrongType = require("wrongType");

isType = require("isType");

Element = require("./Element");

validTypes = Element.or(Array);

module.exports = Validator("ReactChildren", {
  test: function(value) {
    if (value === false) {
      return true;
    }
    return isType(value, validTypes);
  },
  assert: function(value, key) {
    if (this.test(value)) {
      return;
    }
    return wrongType(validTypes, key);
  }
});

//# sourceMappingURL=map/Children.map
