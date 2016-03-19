var Element, ReactElement, Validator, isType, ref, throwFailure;

throwFailure = require("failure").throwFailure;

ref = require("type-utils"), Validator = ref.Validator, isType = ref.isType;

ReactElement = require("ReactElement");

Element = Validator("Element", function() {
  return function(value, key) {
    var data, reason;
    if (ReactElement.isValidElement(value)) {
      return;
    }
    data = isType(key, Object) ? key : {
      key: key
    };
    data.value = value;
    data.type = type;
    reason = data.key != null ? "'" + data.key + "' must be a ReactElement." : "Expected a ReactElement.";
    return throwFailure(TypeError(reason), data);
  };
});

module.exports = Element();

//# sourceMappingURL=../../map/src/Element.map
