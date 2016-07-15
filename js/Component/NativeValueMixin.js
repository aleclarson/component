var NativeValue, Random, assertType, baseImpl, define, frozen, hasNativeValues, isType, typeImpl;

frozen = require("Property").frozen;

assertType = require("assertType");

Random = require("random");

isType = require("isType");

define = require("define");

NativeValue = require("../Native/Value");

hasNativeValues = Symbol("Component.hasNativeValues");

module.exports = function(type) {
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.methods = {
  defineNativeValues: function(nativeValues) {
    var attachNativeValues, computed, createNativeValues, delegate, detachNativeValues, key, kind, phaseId, value;
    assertType(nativeValues, Object);
    delegate = this._delegate;
    if (!delegate[hasNativeValues]) {
      frozen.define(delegate, hasNativeValues, true);
      kind = delegate._kind;
      if (!(kind && kind.prototype[hasNativeValues])) {
        delegate._didBuild.push(baseImpl.didBuild);
        delegate._initInstance.push(baseImpl.initInstance);
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
    createNativeValues = function(args) {
      var nativeKeys;
      nativeKeys = [];
      for (key in nativeValues) {
        value = nativeValues[key];
        if (computed[key]) {
          value = value.apply(this, args);
        }
        if (value === void 0) {
          continue;
        }
        nativeKeys.push(key);
        frozen.define(this, key, value instanceof NativeValue ? value : NativeValue(value, this.constructor.name + "." + key));
      }
      this.__nativeKeys[phaseId] = nativeKeys;
    };
    delegate._initInstance.push(createNativeValues);
    attachNativeValues = function() {
      var i, len, ref;
      ref = this.__nativeKeys[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        this[key].__attach();
      }
    };
    this._willMount.push(attachNativeValues);
    detachNativeValues = function() {
      var i, len, ref;
      ref = this.__nativeKeys[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        this[key].__detach();
      }
    };
    this._willUnmount.push(detachNativeValues);
  }
};

baseImpl = {};

baseImpl.didBuild = function(type) {
  return frozen.define(type.prototype, hasNativeValues, true);
};

baseImpl.initInstance = function() {
  return frozen.define(this, "__nativeKeys", Object.create(null));
};

//# sourceMappingURL=map/NativeValueMixin.map
