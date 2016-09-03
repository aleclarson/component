var Event, Random, assertType, baseImpl, define, frozen, typeImpl;

frozen = require("Property").frozen;

assertType = require("assertType");

Random = require("random");

define = require("define");

Event = require("Event");

module.exports = function(type) {
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.methods = {
  defineMountedListeners: function(createListeners) {
    var delegate, kind, phaseId, startListeners, stopListeners;
    assertType(createListeners, Function);
    delegate = this._delegate;
    if (!this.__hasMountedListeners) {
      frozen.define(this, "__hasMountedListeners", {
        value: true
      });
      kind = delegate._kind;
      if (!(kind && kind.prototype.__hasMountedListeners)) {
        delegate.didBuild(baseImpl.didBuild);
        delegate.initInstance(baseImpl.initInstance);
      }
    }
    phaseId = Random.id();
    startListeners = function() {
      var i, len, listener, listeners, onAttach;
      listeners = [];
      onAttach = function(listener) {
        return listeners.push(listener);
      };
      onAttach = Event.didAttach(onAttach).start();
      createListeners.call(this);
      onAttach.stop();
      for (i = 0, len = listeners.length; i < len; i++) {
        listener = listeners[i];
        listener.start();
      }
      this.__listeners[phaseId] = listeners;
    };
    this.willMount(startListeners);
    stopListeners = function() {
      var i, len, listener, ref;
      ref = this.__listeners[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        listener = ref[i];
        listener.stop();
      }
    };
    this.willUnmount(stopListeners);
  }
};

baseImpl = {};

baseImpl.didBuild = function(type) {
  return frozen.define(type.prototype, "__hasMountedListeners", {
    value: true
  });
};

baseImpl.initInstance = function() {
  return frozen.define(this, "__listeners", {
    value: Object.create(null)
  });
};

//# sourceMappingURL=map/ListenerMixin.map
