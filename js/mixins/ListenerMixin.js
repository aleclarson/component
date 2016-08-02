var Event, Random, assertType, baseImpl, define, frozen, hasListeners, typeImpl;

frozen = require("Property").frozen;

assertType = require("assertType");

Random = require("random");

define = require("define");

Event = require("Event");

hasListeners = Symbol("Component.hasListeners");

module.exports = function(type) {
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.methods = {
  defineListeners: function(func) {
    var createListeners, delegate, kind, phaseId, startListeners, stopListeners;
    assertType(func, Function);
    delegate = this._delegate;
    if (!this[hasListeners]) {
      frozen.define(this, hasListeners, {
        value: true
      });
      kind = delegate._kind;
      if (!(kind && kind.prototype[hasListeners])) {
        delegate._didBuild.push(baseImpl.didBuild);
        delegate._initInstance.push(baseImpl.initInstance);
      }
    }
    phaseId = Random.id();
    createListeners = function(args) {
      var listeners, onAttach;
      listeners = [];
      onAttach = function(listener) {
        return listeners.push(listener);
      };
      onAttach = Event.didAttach(onAttach);
      onAttach.start();
      func.apply(this, args);
      onAttach.stop();
      return listeners;
    };
    startListeners = function() {
      var i, len, listener, listeners;
      listeners = createListeners();
      for (i = 0, len = listeners.length; i < len; i++) {
        listener = listeners[i];
        listener.start();
      }
      this.__listeners[phaseId] = listeners;
    };
    this._willMount.push(startListeners);
    stopListeners = function() {
      var i, len, listener, ref;
      ref = this.__listeners[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        listener = ref[i];
        listener.stop();
      }
    };
    this._willUnmount.push(stopListeners);
  }
};

baseImpl = {};

baseImpl.didBuild = function(type) {
  return frozen.define(type.prototype, hasListeners, {
    value: true
  });
};

baseImpl.initInstance = function() {
  return frozen.define(this, "__listeners", {
    value: Object.create(null)
  });
};

//# sourceMappingURL=map/ListenerMixin.map
