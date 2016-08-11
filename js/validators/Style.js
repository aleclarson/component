var Style, Validator, Void, isType, validTypes, wrongType;

Validator = require("Validator");

wrongType = require("wrongType");

isType = require("isType");

Void = require("Void");

validTypes = [Object, Array, Void];

module.exports = Style = Validator("Style", {
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