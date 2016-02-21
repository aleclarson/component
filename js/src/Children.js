var Children, ReactElement, Validator, Void, isType, ref, reportFailure;

ref = require("type-utils"), Void = ref.Void, Validator = ref.Validator, isType = ref.isType;

reportFailure = require("report-failure");

ReactElement = require("ReactElement");

Children = Validator("Children", function() {
  return function(value, key) {
    var error;
    if (ReactElement.isValidElement(value)) {
      return;
    }
    if (isType(value, [Array, Void])) {
      return;
    }
    error = TypeError("'" + key + "' must be an Array or ReactElement.");
    return reportFailure(error, {
      key: key,
      value: value
    });
  };
});

module.exports = Children();

//# sourceMappingURL=../../map/src/Children.map
