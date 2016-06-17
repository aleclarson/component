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
      frozen.define(this, hasListeners, true);
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
      onAttach = Event.didAttach(function(listener) {
        return listeners.push(listener);
      });
      onAttach.start();
      func.apply(this, args);
      onAttach.stop();
      this.__listeners[phaseId] = listeners;
    };
    delegate._initInstance.push(createListeners);
    startListeners = function() {
      var i, len, listener, ref;
      ref = this.__listeners[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        listener = ref[i];
        listener.start();
      }
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
  return frozen.define(type.prototype, hasListeners, true);
};

baseImpl.initInstance = function() {
  return frozen.define(this, "__listeners", Object.create(null));
};

//# sourceMappingURL=../../../map/src/Component/ListenerMixin.map
