var Event, Factory, Immutable, NativeMap, NativeValue, assert, assertType, isKind, isType, ref, setType, sync;

ref = require("type-utils"), isType = ref.isType, isKind = ref.isKind, setType = ref.setType, assert = ref.assert, assertType = ref.assertType;

sync = require("io").sync;

Immutable = require("immutable");

Factory = require("factory");

Event = require("event");

NativeValue = require("./NativeValue");

module.exports = NativeMap = Factory("NativeMap", {
  customValues: {
    values: {
      get: function() {
        return this._getValues();
      }
    }
  },
  initFrozenValues: function() {
    return {
      didSet: Event()
    };
  },
  initValues: function(values) {
    return {
      _values: values,
      _nativeMaps: {},
      _nativeValues: {},
      _nativeListeners: {}
    };
  },
  attach: function(newValues) {
    this._detachOldValues(newValues);
    return this._attachNewValues(newValues);
  },
  detach: function() {
    this._detachNativeValues();
    this._detachNativeMaps();
    this._nativeMaps = {};
    this._nativeValues = {};
    return this._nativeListeners = {};
  },
  _didSet: function(newValues) {
    return this.didSet.emit(newValues);
  },
  _getValues: function() {
    var values;
    values = {};
    sync.each(this._values, function(value, key) {
      return values[key] = value;
    });
    sync.each(this._nativeValues, function(nativeValue, key) {
      return values[key] = nativeValue.value;
    });
    sync.each(this._nativeMaps, function(nativeMap, key) {
      return values[key] = nativeMap.values;
    });
    return values;
  },
  _attachValue: function(value, key) {
    var values;
    if (isKind(value, NativeValue)) {
      if (this._nativeValues[key] != null) {
        return;
      }
      this._nativeValues[key] = value;
      this._attachNativeValue(value, key);
      return;
    }
    if (isType(value, Object)) {
      values = value;
      value = this._nativeMaps[key] || NativeMap({});
      value.attach(values);
    }
    if (isKind(value, NativeMap)) {
      if (this._nativeMaps[key] != null) {
        return;
      }
      this._nativeMaps[key] = value;
      this._attachNativeValue(value, key);
      return;
    }
    return this._values[key] = value;
  },
  _attachNewValues: function(newValues) {
    if (newValues == null) {
      return;
    }
    return sync.each(newValues, (function(_this) {
      return function(value, key) {
        return _this._attachValue(value, key);
      };
    })(this));
  },
  _detachOldValues: function(newValues) {
    assertType(newValues, Object);
    sync.each(this._nativeValues, (function(_this) {
      return function(nativeValue, key) {
        if (nativeValue !== newValues[key]) {
          _this._detachNativeValue(nativeValue, key);
          return delete _this._nativeValues[key];
        }
      };
    })(this));
    return sync.each(this._nativeMaps, (function(_this) {
      return function(nativeMap, key) {
        if (nativeMap !== newValues[key]) {
          _this._detachNativeValue(nativeMap, key);
          return delete _this._nativeMaps[key];
        } else {
          return nativeMap._detachOldValues(newValues[key]);
        }
      };
    })(this));
  },
  _detachNativeValues: function() {
    return sync.each(this._nativeValues, (function(_this) {
      return function(nativeValue, key) {
        return _this._detachNativeValue(nativeValue, key);
      };
    })(this));
  },
  _detachNativeMaps: function() {
    return sync.each(this._nativeMaps, (function(_this) {
      return function(nativeMap, key) {
        _this._detachNativeValue(nativeMap, key);
        return nativeMap.detach();
      };
    })(this));
  },
  _attachNativeValue: function(nativeValue, key) {
    return this._nativeListeners[key] = nativeValue.didSet((function(_this) {
      return function(newValue) {
        var newValues;
        newValues = {};
        newValues[key] = newValue;
        return _this._didSet(newValues);
      };
    })(this));
  },
  _detachNativeValue: function(nativeValue, key) {
    this._nativeListeners[key].stop();
    return delete this._nativeListeners[key];
  }
});

//# sourceMappingURL=../../map/src/NativeMap.map
