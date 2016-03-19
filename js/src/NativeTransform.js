var Factory, NativeMap, NativeValue, assertType, isKind, isType, ref, sync;

ref = require("type-utils"), isType = ref.isType, isKind = ref.isKind, assertType = ref.assertType;

sync = require("io").sync;

Factory = require("factory");

NativeValue = require("./NativeValue");

NativeMap = require("./NativeMap");

module.exports = Factory("NativeTransform", {
  kind: NativeMap,
  create: function() {
    return NativeMap({});
  },
  init: function(values) {
    assertType(values, Array);
    return this.attach(values);
  },
  _didSet: function(newValues) {
    return this.didSet.emit(this.values);
  },
  _getValues: function() {
    var values;
    values = [];
    sync.each(this._values, function(value, key) {
      var index, ref1, transform;
      ref1 = key.split("."), index = ref1[0], key = ref1[1];
      transform = values[index] != null ? values[index] : values[index] = {};
      return transform[key] = value;
    });
    sync.each(this._nativeValues, function(nativeValue, key) {
      var index, ref1, transform;
      ref1 = key.split("."), index = ref1[0], key = ref1[1];
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
        if (isKind(value, NativeValue)) {
          _this._nativeValues[key] = value;
          _this._attachNativeValue(value, key);
          return;
        }
        return _this._values[key] = value;
      };
    })(this));
  },
  _detachOldValues: function(newValues) {
    return this.detach();
  }
});

//# sourceMappingURL=../../map/src/NativeTransform.map
