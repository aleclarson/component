var Style, Validator, Void, isType, ref, reportFailure;

ref = require("type-utils"), Void = ref.Void, Validator = ref.Validator, isType = ref.isType;

reportFailure = require("report-failure");

Style = Validator("Style", function() {
  return function(value, key) {
    var error;
    if (isType(value, [Object, Array, Number, Function, Void])) {
      return;
    }
    error = TypeError("'" + key + "' must be a Style.");
    return reportFailure(error, {
      key: key,
      value: value
    });
  };
});

module.exports = Style();

//# sourceMappingURL=../../map/src/Style.map
