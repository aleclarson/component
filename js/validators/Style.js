var Validator, isType, validTypes, wrongType;

Validator = require("Validator");

wrongType = require("wrongType");

isType = require("isType");

validTypes = Object.or(Array);

module.exports = Validator("ReactStyle", {
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

//# sourceMappingURL=map/Style.map
