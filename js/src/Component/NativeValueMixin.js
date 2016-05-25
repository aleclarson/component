var NativeValue, Property, Random, assertType, define, frozen, hasNativeValues, isType, typeImpl;

assertType = require("assertType");

Property = require("Property");

Random = require("random");

isType = require("isType");

define = require("define");

NativeValue = require("../Native/Value");

hasNativeValues = Symbol("Component.hasNativeValues");

frozen = Property({
  frozen: true
});

module.exports = function(type) {
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.methods = {
  defineNativeValues: function(nativeValues) {
    var computed, delegate, key, kind, phaseId, value;
    assertType(nativeValues, Object);
    delegate = this._delegate;
    kind = delegate._kind;
    if (!delegate[hasNativeValues]) {
      frozen.define(delegate, hasNativeValues, true);
      if (!(kind && kind.prototype[hasNativeValues])) {
        delegate._didBuild.push(function(type) {
          return frozen.define(type.prototype, hasNativeValues, true);
        });
        delegate._initInstance.push(function() {
          return frozen.define(this, "__nativeKeys", Object.create(null));
        });
      }
    }
    computed = Object.create(null);
    for (key in nativeValues) {
      value = nativeValues[key];
      if (isType(value, Function)) {
        computed[key] = true;
      }
    }
    phaseId = Random.id();
    delegate._initInstance.push(function(args) {
      var keys;
      keys = [];
      for (key in nativeValues) {
        value = nativeValues[key];
        if (computed[key]) {
          value = value.apply(this, args);
        }
        if (value === void 0) {
          continue;
        }
        keys.push(key);
        frozen.define(this, key, value instanceof NativeValue ? value : NativeValue(value, this.constructor.name + "." + key));
      }
      this.__nativeKeys[phaseId] = keys;
    });
    this._willMount.push(function() {
      var i, len, ref;
      delegate = this._delegate;
      ref = delegate.__nativeKeys[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        delegate[key].__attach();
      }
    });
    this._willUnmount.push(function() {
      var i, len, ref;
      delegate = this._delegate;
      ref = delegate.__nativeKeys[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        delegate[key].__detach();
      }
    });
  }
};

//# sourceMappingURL=../../../map/src/Component/NativeValueMixin.map
