var Style, Validator, Void, isType, ref, throwFailure;

ref = require("type-utils"), Void = ref.Void, Validator = ref.Validator, isType = ref.isType;

throwFailure = require("failure").throwFailure;

Style = Validator("Style", function() {
  return function(value, key) {
    var error;
    if (isType(value, [Object, Array, Number, Function, Void])) {
      return;
    }
    error = TypeError("'" + key + "' must be a Style.");
    return throwFailure(error, {
      key: key,
      value: value
    });
  };
});

module.exports = Style();

//# sourceMappingURL=../../map/src/Style.map
