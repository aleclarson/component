var Event, Property, Random, assertType, define, frozen, hasListeners, typeImpl;

assertType = require("assertType");

Property = require("Property");

Random = require("random");

define = require("define");

Event = require("event");

hasListeners = Symbol("Component.hasListeners");

frozen = Property({
  frozen: true
});

module.exports = function(type) {
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.methods = {
  defineListeners: function(createListeners) {
    var delegate, kind, phaseId;
    assertType(createListeners, Function);
    delegate = this._delegate;
    kind = delegate._kind;
    if (!this[hasListeners]) {
      define(this, hasListeners, true);
      if (!(kind && kind.prototype[hasListeners])) {
        delegate._didBuild.push(function(type) {
          return define(type.prototype, hasListeners, true);
        });
        delegate._initInstance.push(function() {
          return define(this, "__listeners", Object.create(null));
        });
      }
    }
    phaseId = Random.id();
    delegate._initInstance.push(function(args) {
      var listeners, onListen;
      listeners = [];
      onListen = Event.didListen(function(listener) {
        listener._defuse();
        return listeners.push(listener);
      });
      createListeners.apply(this, args);
      onListen.stop();
      this.__listeners[phaseId] = listeners;
    });
    this._willMount.push(function() {
      var i, len, listener, ref;
      ref = this.__listeners[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        listener = ref[i];
        listener.start();
      }
    });
    this._willUnmount.push(function() {
      var i, len, listener, ref;
      ref = this.__listeners[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        listener = ref[i];
        listener.stop();
      }
    });
  }
};
