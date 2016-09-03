var NativeValue, ValueMapper, assertType, baseImpl, bind, frozen, isType, sync, typeImpl;

frozen = require("Property").frozen;

ValueMapper = require("ValueMapper");

assertType = require("assertType");

isType = require("isType");

bind = require("bind");

sync = require("sync");

NativeValue = require("../native/NativeValue");

module.exports = function(type) {
  return type.defineMethods(typeImpl.defineMethods);
};

typeImpl = {
  defineMethods: {
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
        }
      }
      if (isType(nativeValues, Object)) {
        nativeValues = sync.map(nativeValues, function(value) {
          if (isType(value, Function)) {
            return function() {
              return bind.func(value, this);
            };
          }
          return value;
        });
      }
      nativeValues = ValueMapper({
        values: nativeValues,
        define: function(obj, key, value) {
          if (value === void 0) {
            return;
          }
          if (!(value instanceof NativeValue)) {
            value = NativeValue(value, obj.constructor.name + "." + key);
          }
          if (isDev) {
            frozen.define(obj, key, {
              value: value
            });
          } else {
            obj[key] = value;
          }
          obj.__nativeKeys.push(key);
          value.__attach();
        }
      });
      delegate._phases.init.push(function(args) {
        return nativeValues.define(this, args);
      });
    }
  }
};

baseImpl = {
  didBuild: function(type) {
    return frozen.define(type.prototype, "__hasNativeValues", {
      value: true
    });
  },
  initInstance: function() {
    return frozen.define(this, "__nativeKeys", {
      value: []
    });
  }
};

//# sourceMappingURL=map/NativeValueMixin.map
