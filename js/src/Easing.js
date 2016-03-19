var Easing, ReactEasing, assert, assertType, ref;

ref = require("type-utils"), assert = ref.assert, assertType = ref.assertType;

ReactEasing = require("Easing");

module.exports = Easing = function(namePath) {
  var easing, i, len, name, names, ref1, result;
  assertType(namePath, String);
  result = Easing.cache[namePath];
  if (result != null) {
    return result;
  }
  names = namePath.split(".");
  name = names.pop();
  result = ReactEasing[name];
  assert(result != null, {
    name: name,
    reason: "Invalid easing name!"
  });
  ref1 = names.reverse();
  for (i = 0, len = ref1.length; i < len; i++) {
    name = ref1[i];
    easing = ReactEasing[name];
    assert(easing != null, {
      name: name,
      reason: "Invalid easing name!"
    });
    result = easing(result);
  }
  return Easing.cache[namePath] = result;
};

Easing.cache = Object.create(null);

Easing.bezier = ReactEasing.bezier;

//# sourceMappingURL=../../map/src/Easing.map
