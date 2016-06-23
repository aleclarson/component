var Event, NativeMap, NativeValue, Type, assertType, cloneObject, getArgProp, isType, type;

cloneObject = require("cloneObject");

assertType = require("assertType");

getArgProp = require("getArgProp");

isType = require("isType");

Event = require("Event");

Type = require("Type");

NativeValue = require("./Value");

type = Type("NativeMap");

type.defineProperties({
  values: {
    get: function() {
      return this.__getValues();
    }
  }
});

type.defineFrozenValues({
  didSet: function() {
    return Event();
  }
});

type.defineValues({
  __values: getArgProp(0),
  __nativeMaps: function() {
    return {};
  },
  __nativeValues: function() {
    return {};
  },
  __nativeListeners: function() {
    return {};
  }
});

type.defineMethods({
  attach: function(newValues) {
    this.__detachOldValues(newValues);
    this.__attachNewValues(newValues);
  },
  detach: function() {
    this.__detachNativeValues();
    this.__detachNativeMaps();
    this.__nativeMaps = {};
    this.__nativeValues = {};
    this.__nativeListeners = {};
  },
  __didSet: function(newValues) {
    return this.didSet.emit(newValues);
  },
  __getValues: function() {
    var key, nativeMap, nativeValue, ref, ref1, values;
    values = cloneObject(this.__values);
    ref = this.__nativeValues;
    for (key in ref) {
      nativeValue = ref[key];
      values[key] = nativeValue.value;
    }
    ref1 = this.__nativeMaps;
    for (key in ref1) {
      nativeMap = ref1[key];
      values[key] = nativeMap.values;
    }
    return values;
  },
  __attachValue: function(value, key) {
    var values;
    if (isType(value, NativeValue.Kind)) {
      if (this.__nativeValues[key] != null) {
        return;
      }
      this.__nativeValues[key] = value;
      this.__attachNativeValue(value, key);
      return;
    }
    if (isType(value, Object)) {
      values = value;
      value = this.__nativeMaps[key] || NativeMap({});
      value.attach(values);
    }
    if (isType(value, NativeMap.Kind)) {
      if (this.__nativeMaps[key] != null) {
        return;
      }
      this.__nativeMaps[key] = value;
      this.__attachNativeValue(value, key);
      return;
    }
    this.__values[key] = value;
  },
  __attachNewValues: function(newValues) {
    var key, value;
    if (!newValues) {
      return;
    }
    for (key in newValues) {
      value = newValues[key];
      this.__attachValue(value, key);
    }
  },
  __detachOldValues: function(newValues) {
    var key, nativeMap, nativeMaps, nativeValue, nativeValues;
    assertType(newValues, Object);
    nativeValues = this.__nativeValues;
    for (key in nativeValues) {
      nativeValue = nativeValues[key];
      if (nativeValue === newValues[key]) {
        continue;
      }
      this.__detachNativeValue(nativeValue, key);
      delete nativeValues[key];
    }
    nativeMaps = this.__nativeMaps;
    for (key in nativeMaps) {
      nativeMap = nativeMaps[key];
      if (nativeMap === newValues[key]) {
        nativeMap._detachOldValues(newValues[key]);
        continue;
      }
      this.__detachNativeValue(nativeMap, key);
      delete nativeMaps[key];
    }
  },
  __detachNativeValues: function() {
    var key, nativeValue, ref;
    ref = this.__nativeValues;
    for (key in ref) {
      nativeValue = ref[key];
      this.__detachNativeValue(nativeValue, key);
    }
  },
  __detachNativeMaps: function() {
    var key, nativeMap, ref;
    ref = this.__nativeMaps;
    for (key in ref) {
      nativeMap = ref[key];
      this.__detachNativeValue(nativeMap, key);
      nativeMap.detach();
    }
  },
  __attachNativeValue: function(nativeValue, key) {
    var listener, onChange;
    onChange = (function(_this) {
      return function(newValue) {
        var newValues;
        newValues = {};
        newValues[key] = newValue;
        return _this.__didSet(newValues);
      };
    })(this);
    listener = nativeValue.didSet(onChange);
    this.__nativeListeners[key] = listener.start();
  },
  __detachNativeValue: function(nativeValue, key) {
    this.__nativeListeners[key].stop();
    delete this.__nativeListeners[key];
  }
});

module.exports = NativeMap = type.build();

//# sourceMappingURL=../../../map/src/Native/Map.map
