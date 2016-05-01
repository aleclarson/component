var NativeMap, NativeValue, Type, isType, sync, type;

require("isDev");

isType = require("type-utils").isType;

Type = require("Type");

sync = require("sync");

NativeValue = require("./Value");

NativeMap = require("./Map");

type = Type("NativeTransform");

type.inherits(NativeMap);

type.argumentTypes = {
  values: Array
};

type.createInstance(function() {
  return NativeMap({});
});

type.initInstance(function(values) {
  return this.attach(values);
});

type.defineMethods({
  __didSet: function(newValues) {
    return this.didSet.emit(this.values);
  },
  __getValues: function() {
    var values;
    values = [];
    sync.each(this.__values, function(value, key) {
      var index, ref, transform;
      ref = key.split("."), index = ref[0], key = ref[1];
      transform = values[index] != null ? values[index] : values[index] = {};
      return transform[key] = value;
    });
    sync.each(this.__nativeValues, function(nativeValue, key) {
      var index, ref, transform;
      ref = key.split("."), index = ref[0], key = ref[1];
      transform = values[index] != null ? values[index] : values[index] = {};
      return transform[key] = nativeValue.value;
    });
    return values;
  },
  _attachValue: function(transform, index) {
    if (!isType(transform, Object)) {
      return;
    }
    return sync.each(transform, (function(_this) {
      return function(value, key) {
        key = index + "." + key;
        if (isType(value, NativeValue.Kind)) {
          _this.__nativeValues[key] = value;
          _this.__attachNativeValue(value, key);
          return;
        }
        return _this.__values[key] = value;
      };
    })(this));
  },
  _detachOldValues: function(newValues) {
    return this.detach();
  }
});

module.exports = type.build();

//# sourceMappingURL=../../../map/src/Native/Transform.map
