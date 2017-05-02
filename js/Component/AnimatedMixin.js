// Generated by CoffeeScript 1.12.4
var AnimatedValue, defineAnimatedValue, defineNativeValue, frozen, methods;

AnimatedValue = require("Animated").AnimatedValue;

frozen = require("Property").frozen;

module.exports = function(type) {
  return type.defineMethods(methods);
};

methods = {
  defineAnimatedValues: function(values) {
    this._delegate._values.push(defineAnimatedValue, values);
  },
  defineNativeValues: function(values) {
    this._delegate._values.push(defineNativeValue, values);
  }
};

defineAnimatedValue = function(obj, key, value) {
  return frozen.define(obj, key, {
    value: AnimatedValue(value)
  });
};

defineNativeValue = function(obj, key, value) {
  return frozen.define(obj, key, {
    value: AnimatedValue(value, {
      isNative: true
    })
  });
};