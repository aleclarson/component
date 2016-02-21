var Factory, NativeMap, NativeTransform, Style, assert, assertType, flattenStyle, isType, ref, sync;

ref = require("type-utils"), assert = ref.assert, assertType = ref.assertType, isType = ref.isType;

sync = require("io").sync;

flattenStyle = require("flattenStyle");

Factory = require("factory");

NativeTransform = require("./NativeTransform");

NativeMap = require("./NativeMap");

Style = require("./Style");

module.exports = Factory("NativeStyle", {
  kind: NativeMap,
  create: function() {
    return NativeMap({});
  },
  init: function(values) {
    return this.attach(values);
  },
  attach: function(newValues) {
    var error;
    assertType(newValues, Style);
    newValues = flattenStyle(newValues);
    try {
      newValues = sync.filter(newValues, (function(_this) {
        return function(value, key) {
          return value != null;
        };
      })(this));
    } catch (_error) {
      error = _error;
      try {
        reportFailure(error, {
          newValues: newValues,
          style: this
        });
      } catch (_error) {}
    }
    return NativeMap.prototype.attach.call(this, newValues);
  },
  _getValues: function() {
    var values;
    values = NativeMap.prototype._getValues.call(this);
    sync.each(values, (function(_this) {
      return function(value, key) {
        return assert(value != null, {
          style: _this,
          key: key,
          reason: "Value must be defined!"
        });
      };
    })(this));
    return values;
  },
  _attachValue: function(value, key) {
    if (key === "transform") {
      if (!isType(value, Array)) {
        return;
      }
      if (this._nativeMaps[key] != null) {
        return;
      }
      value = NativeTransform(value);
    }
    return NativeMap.prototype._attachValue.call(this, value, key);
  }
});

//# sourceMappingURL=../../map/src/NativeStyle.map
