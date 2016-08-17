var NativeValue, ValueMapper, assertType, baseImpl, frozen, isType, typeImpl;

frozen = require("Property").frozen;

ValueMapper = require("ValueMapper");

assertType = require("assertType");

isType = require("isType");

NativeValue = require("../native/NativeValue");

module.exports = function(type) {
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.methods = {
  defineNativeValues: function(nativeValues) {
    var delegate, kind;
    assertType(nativeValues, Object.or(Function));
    delegate = this._delegate;
    if (!delegate.__hasNativeValues) {
      frozen.define(delegate, "__hasNativeValues", {
        value: true
      });
      kind = delegate._kind;
      if (!(kind && kind.prototype.__hasNativeValues)) {
        delegate.didBuild(baseImpl.didBuild);
        delegate.initInstance(baseImpl.initInstance);
        this._willMount.push(baseImpl.attachNativeValues);
        this._willUnmount.push(baseImpl.detachNativeValues);
      }
    }
    nativeValues = ValueMapper({
      values: nativeValues,
      define: function(obj, key, value) {
        if (value === void 0) {
          return;
        }
        obj.__nativeKeys.push(key);
        return frozen.define(obj, key, {
          value: value instanceof NativeValue ? value : NativeValue(value, obj.constructor.name + "." + key)
        });
      }
    });
    delegate._initPhases.push(function(args) {
      return nativeValues.define(this, args);
    });
  }
};

baseImpl = {};

baseImpl.didBuild = function(type) {
  return frozen.define(type.prototype, "__hasNativeValues", {
    value: true
  });
};

baseImpl.initInstance = function() {
  return frozen.define(this, "__nativeKeys", {
    value: []
  });
};

baseImpl.attachNativeValues = function() {
  var i, key, len, ref;
  ref = this.__nativeKeys;
  for (i = 0, len = ref.length; i < len; i++) {
    key = ref[i];
    this[key].__attach();
  }
};

baseImpl.detachNativeValues = function() {
  var i, key, len, ref;
  ref = this.__nativeKeys;
  for (i = 0, len = ref.length; i < len; i++) {
    key = ref[i];
    this[key].__detach();
  }
};

//# sourceMappingURL=map/NativeValueMixin.map
