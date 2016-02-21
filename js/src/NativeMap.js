var Factory, Immutable, Listenable, NativeMap, NativeValue, assert, assertType, isKind, isType, ref, setType, sync;

ref = require("type-utils"), isType = ref.isType, isKind = ref.isKind, setType = ref.setType, assert = ref.assert, assertType = ref.assertType;

sync = require("io").sync;

Listenable = require("listenable");

Immutable = require("immutable");

Factory = require("factory");

NativeValue = require("./NativeValue");

module.exports = NativeMap = Factory("NativeMap", {
  customValues: {
    values: {
      get: function() {
        return this._getValues();
      }
    }
  },
  initValues: function(values) {
    return {
      _values: values,
      _nativeMaps: {},
      _nativeValues: {},
      _nativeListeners: {}
    };
  },
  init: function() {
    return Listenable(this, {
      eventNames: true
    });
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
    return this._emit("didSet", newValues);
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
    return sync.each(newValues, this._attachValue.bind(this));
  },
  _detachOldValues: function(newValues) {
    sync.each(this._nativeValues, (function(_this) {
      return function(nativeValue, key) {
        if (nativeValue !== (newValues != null ? newValues[key] : void 0)) {
          _this._detachNativeValue(nativeValue, key);
          return delete _this._nativeValues[key];
        }
      };
    })(this));
    return sync.each(this._nativeMaps, (function(_this) {
      return function(nativeMap, key) {
        if (nativeMap !== (newValues != null ? newValues[key] : void 0)) {
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
    var base;
    return nativeValue.addListener("didSet", (base = this._nativeListeners)[key] != null ? base[key] : base[key] = (function(_this) {
      return function(newValue) {
        var newValues;
        newValues = {};
        newValues[key] = newValue;
        return _this._didSet(newValues);
      };
    })(this));
  },
  _detachNativeValue: function(nativeValue, key) {
    return nativeValue.removeListener("didSet", this._nativeListeners[key]);
  }
});

//# sourceMappingURL=../../map/src/NativeMap.map
