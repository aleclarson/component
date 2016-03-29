var Style, Validator, Void, isType, ref, throwFailure, valueTypes;

ref = require("type-utils"), Void = ref.Void, Validator = ref.Validator, isType = ref.isType;

throwFailure = require("failure").throwFailure;

valueTypes = [Object, Array, Number, Function, Void];

module.exports = Style = Validator("Style", {
  validate: function(value, key) {
    if (isType(value, valueTypes)) {
      return true;
    }
    return {
      key: key,
      value: value,
      type: Style
    };
  },
  fail: function(values) {
    var error;
    if (values.key) {
      error = TypeError("'" + values.key + "' must be a Style!");
    } else {
      error = TypeError("Expected a Style.");
    }
    return throwFailure(error, values);
  }
});

//# sourceMappingURL=../../map/src/Style.map
