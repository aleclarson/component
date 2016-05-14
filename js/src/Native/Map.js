var Event, NativeMap, NativeValue, Type, assertType, isType, sync, type;

assertType = require("assertType");

isType = require("isType");

Event = require("event");

Type = require("Type");

sync = require("sync");

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
  __values: function(values) {
    return values;
  },
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
    return this.__attachNewValues(newValues);
  },
  detach: function() {
    this.__detachNativeValues();
    this.__detachNativeMaps();
    this.__nativeMaps = {};
    this.__nativeValues = {};
    return this.__nativeListeners = {};
  },
  __didSet: function(newValues) {
    return this.didSet.emit(newValues);
  },
  __getValues: function() {
    var values;
    values = {};
    sync.each(this.__values, function(value, key) {
      return values[key] = value;
    });
    sync.each(this.__nativeValues, function(nativeValue, key) {
      return values[key] = nativeValue.value;
    });
    sync.each(this.__nativeMaps, function(nativeMap, key) {
      return values[key] = nativeMap.values;
    });
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
    return this.__values[key] = value;
  },
  __attachNewValues: function(newValues) {
    if (newValues == null) {
      return;
    }
    return sync.each(newValues, (function(_this) {
      return function(value, key) {
        return _this.__attachValue(value, key);
      };
    })(this));
  },
  __detachOldValues: function(newValues) {
    assertType(newValues, Object);
    sync.each(this.__nativeValues, (function(_this) {
      return function(nativeValue, key) {
        if (nativeValue !== newValues[key]) {
          _this.__detachNativeValue(nativeValue, key);
          return delete _this.__nativeValues[key];
        }
      };
    })(this));
    return sync.each(this.__nativeMaps, (function(_this) {
      return function(nativeMap, key) {
        if (nativeMap !== newValues[key]) {
          _this.__detachNativeValue(nativeMap, key);
          return delete _this.__nativeMaps[key];
        } else {
          return nativeMap._detachOldValues(newValues[key]);
        }
      };
    })(this));
  },
  __detachNativeValues: function() {
    return sync.each(this.__nativeValues, (function(_this) {
      return function(nativeValue, key) {
        return _this.__detachNativeValue(nativeValue, key);
      };
    })(this));
  },
  __detachNativeMaps: function() {
    return sync.each(this.__nativeMaps, (function(_this) {
      return function(nativeMap, key) {
        _this.__detachNativeValue(nativeMap, key);
        return nativeMap.detach();
      };
    })(this));
  },
  __attachNativeValue: function(nativeValue, key) {
    return this.__nativeListeners[key] = nativeValue.didSet((function(_this) {
      return function(newValue) {
        var newValues;
        newValues = {};
        newValues[key] = newValue;
        return _this.__didSet(newValues);
      };
    })(this));
  },
  __detachNativeValue: function(nativeValue, key) {
    this.__nativeListeners[key].stop();
    return delete this.__nativeListeners[key];
  }
});

module.exports = NativeMap = type.build();

//# sourceMappingURL=../../../map/src/Native/Map.map
