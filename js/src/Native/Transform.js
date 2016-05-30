var NativeMap, NativeValue, Type, isConstructor, type;

require("isDev");

isConstructor = require("isConstructor");

Type = require("Type");

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

type.overrideMethods({
  __didSet: function(newValues) {
    return this.didSet.emit(this.values);
  },
  __getValues: function() {
    var index, key, nativeValue, ref, ref1, ref2, ref3, transform, transforms, value;
    transforms = [];
    ref = this.__values;
    for (key in ref) {
      value = ref[key];
      ref1 = key.split("."), index = ref1[0], key = ref1[1];
      transform = transforms[index] != null ? transforms[index] : transforms[index] = {};
      transform[key] = value;
    }
    ref2 = this.__nativeValues;
    for (key in ref2) {
      nativeValue = ref2[key];
      ref3 = key.split("."), index = ref3[0], key = ref3[1];
      transform = transforms[index] != null ? transforms[index] : transforms[index] = {};
      transform[key] = nativeValue.value;
    }
    return transforms;
  },
  __attachValue: function(transform, index) {
    var key, value;
    if (!isConstructor(transform, Object)) {
      return;
    }
    for (key in transform) {
      value = transform[key];
      key = index + "." + key;
      if (value instanceof NativeValue) {
        this.__nativeValues[key] = value;
        this.__attachNativeValue(value, key);
        return;
      }
      this.__values[key] = value;
    }
  },
  __detachOldValues: function(newValues) {
    return this.detach();
  }
});

module.exports = type.build();
