var Event, assertType, frozen, hasMountedListeners, startListeners, stopListeners, typeImpl;

frozen = require("Property").frozen;

assertType = require("assertType");

Event = require("Event");

module.exports = function(type) {
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.methods = {
  defineMountedListeners: function(createListeners) {
    var delegate, kind;
    assertType(createListeners, Function);
    delegate = this._delegate;
    if (!this.__hasMountedListeners) {
      frozen.define(this, "__hasMountedListeners", {
        value: true
      });
      kind = delegate._kind;
      if (!(kind && kind.prototype.__hasMountedListeners)) {
        delegate.didBuild(hasMountedListeners);
        this.willMount(startListeners);
        this.willUnmount(stopListeners);
      }
    }
    delegate.initInstance(function() {
      var i, len, listener, listeners, onAttach;
      listeners = this.__mountedListeners || [];
      onAttach = Event.didAttach(function(listener) {
        return listeners.push(listener);
      }).start();
      createListeners.call(this);
      onAttach.detach();
      for (i = 0, len = listeners.length; i < len; i++) {
        listener = listeners[i];
        listener.start();
      }
      this.__mountedListeners || frozen.define(this, "__mountedListeners", {
        value: listeners
      });
    });
  }
};

hasMountedListeners = function(type) {
  return frozen.define(type.prototype, "__hasMountedListeners", {
    value: true
  });
};

startListeners = function() {
  var i, len, listener, ref;
  ref = this.__mountedListeners;
  for (i = 0, len = ref.length; i < len; i++) {
    listener = ref[i];
    listener.start();
  }
};

stopListeners = function() {
  var i, len, listener, ref;
  ref = this.__mountedListeners;
  for (i = 0, len = ref.length; i < len; i++) {
    listener = ref[i];
    listener.stop();
  }
};

//# sourceMappingURL=map/ListenerMixin.map
