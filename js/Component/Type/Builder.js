var Component, Type, assert, assertType, define, isType, type;

assertType = require("assertType");

isType = require("isType");

assert = require("assert");

define = require("define");

Type = require("Type");

Component = require("..");

type = Type("ComponentTypeBuilder");

type.inherits(Type.Builder);

type._initInstance.unshift(function() {
  return this._tracer.trace();
});

type.overrideMethods({
  inherits: function(kind) {
    this.__super(arguments);
    if (kind instanceof Component.Type) {
      this._componentType.inherits(kind.View);
    }
  }
});

type.addMixins([require("./ViewMixin")]);

module.exports = type.build();

//# sourceMappingURL=map/Builder.map
