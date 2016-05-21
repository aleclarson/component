var Event, assertType, define, typeMethods;

assertType = require("assertType");

define = require("define");

Event = require("event");

module.exports = function(type) {
  return type.defineMethods(typeMethods);
};

typeMethods = {
  defineListeners: function(createListeners) {
    assertType(createListeners, Function);
    if (!this._hasListeners) {
      define(this, "_hasListeners", true);
      this._hasListeners = true;
      this._initInstance.push(function() {
        return define(this, "__listeners", []);
      });
      this.willMount(function() {
        var i, len, listener, ref;
        ref = this.__listeners;
        for (i = 0, len = ref.length; i < len; i++) {
          listener = ref[i];
          listener.start();
        }
      });
      this.willUnmount(function() {
        var i, len, listener, ref;
        ref = this.__listeners;
        for (i = 0, len = ref.length; i < len; i++) {
          listener = ref[i];
          listener.stop();
        }
      });
    }
    return this._initInstance.push(function(args) {
      var onListen;
      onListen = Event.didListen((function(_this) {
        return function(listener) {
          listener.stop();
          return _this.__listeners.push(listener);
        };
      })(this));
      createListeners.apply(this, args);
      return onListen.stop();
    });
  }
};

//# sourceMappingURL=../../../map/src/Component/ListenerMixin.map
