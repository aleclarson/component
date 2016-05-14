var NativeMap, NativeTransform, Style, Type, assert, assertType, isType, sync, type;

require("isDev");

assertType = require("assertType");

isType = require("isType");

assert = require("assert");

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
