var NativeValue, Property, assertType, define, isType, typeMethods;

assertType = require("assertType");

Property = require("Property");

isType = require("isType");

define = require("define");

NativeValue = require("../Native/Value");

module.exports = function(type) {
  return type.defineMethods(typeMethods);
};

typeMethods = {
  defineNativeValues: function(values) {
    var computed, key, prop, value;
    assertType(values, Object);
    if (!this._hasNativeValues) {
      define(this, "_hasNativeValues", true);
      this._initInstance.push(function() {
        return define(this, "__nativeValues", []);
      });
      this.willMount(function() {
        var i, key, len, ref;
        ref = this.__nativeValues;
        for (i = 0, len = ref.length; i < len; i++) {
          key = ref[i];
          this[key].__attach();
        }
      });
      this.willUnmount(function() {
        var i, key, len, ref;
        ref = this.__nativeValues;
        for (i = 0, len = ref.length; i < len; i++) {
          key = ref[i];
          this[key].__detach();
        }
      });
    }
    computed = Object.create(null);
    for (key in values) {
      value = values[key];
      if (isType(value, Function)) {
        computed[key] = true;
      }
    }
    prop = Property({
      frozen: true
    });
    return this._initInstance.push(function(args) {
      for (key in values) {
        value = values[key];
        if (computed[key]) {
          value = value.apply(this, args);
        }
        if (value === void 0) {
          continue;
        }
        this.__nativeValues.push(key);
        prop.define(this, key, value instanceof NativeValue ? value : NativeValue(value, this.constructor.name + "." + key));
      }
    });
  }
};

//# sourceMappingURL=../../../map/src/Component/NativeValueMixin.map
