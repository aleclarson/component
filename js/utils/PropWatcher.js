// Generated by CoffeeScript 1.12.4
var AnimatedValue, Type, sync, type;

AnimatedValue = require("Animated").AnimatedValue;

Type = require("Type");

sync = require("sync");

type = Type("PropWatcher");

type.defineValues(function() {
  return {
    _values: {},
    _listeners: {}
  };
});

type.defineMethods({
  add: function(key, callback) {
    var listener;
    if (listener = this._listeners[key]) {
      this._listeners[key] = function() {
        listener.apply(this, arguments);
        return callback.apply(this, arguments);
      };
      return;
    }
    this._listeners[key] = callback;
  },
  start: function(props, context) {
    var values;
    values = this._values;
    sync.each(this._listeners, function(listener, key) {
      var value;
      value = props[key];
      if (value === void 0) {
        return;
      }
      if (value instanceof AnimatedValue) {
        values[key] = value.get();
        value.didSet(function(value) {
          listener.call(context, value, values[key]);
          values[key] = value;
        });
      } else {
        values[key] = value;
      }
    });
  },
  update: function(props, context) {
    var key, listener, listeners, oldValue, value, values;
    values = this._values;
    listeners = this._listeners;
    for (key in props) {
      value = props[key];
      if (!(listener = listeners[key])) {
        continue;
      }
      if (value === (oldValue = values[key])) {
        continue;
      }
      listener.call(context, value, oldValue);
      values[key] = value;
    }
  }
});

module.exports = type.build();