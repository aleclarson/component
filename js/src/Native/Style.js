var NativeMap, NativeTransform, Style, Type, assert, assertType, isType, ref, sync, throwFailure, type;

require("isDev");

ref = require("type-utils"), assert = ref.assert, assertType = ref.assertType, isType = ref.isType;

throwFailure = require("failure").throwFailure;

sync = require("sync");

Type = require("Type");

NativeTransform = require("./Transform");

NativeMap = require("./Map");

Style = require("../React/Style");

type = Type("NativeStyle");

type.inherits(NativeMap);

type.argumentTypes = {
  values: Style
};

type.createInstance(function() {
  return NativeMap({});
});

type.initInstance(function(values) {
  return this.attach(values);
});

type.defineMethods({
  __attachValue: function(value, key) {
    if (key === "transform") {
      if (!Array.isArray(value)) {
        return;
      }
      if (this.__nativeMaps[key]) {
        return;
      }
      value = NativeTransform(value);
    }
    return NativeMap.prototype.__attachValue.call(this, value, key);
  }
});

module.exports = type.build();

//# sourceMappingURL=../../../map/src/Native/Style.map
