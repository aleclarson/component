var Component, Reaction, Type, assert, assertType, define, guard, isType, type;

assertType = require("assertType");

Reaction = require("reaction");

isType = require("isType");

assert = require("assert");

define = require("define");

guard = require("guard");

Type = require("Type");

Component = require("..");

type = Type("ComponentTypeBuilder");

type.inherits(Type.Builder);

type._initInstance.unshift(function() {
  return this._tracer.trace();
});

type.defineMethods({
  inherits: function(kind) {
    this.__super(arguments);
    if (kind instanceof Component.Type) {
      this._componentType.inherits(kind.View);
    }
  }
});

type.addMixins([require("./ViewMixin")]);

module.exports = type.build();
