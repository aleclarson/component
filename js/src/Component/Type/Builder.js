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

type.overrideMethods({
  inherits: function(kind) {
    this.__super(arguments);
  }
});

type.addMixins([require("./ViewMixin"), require("../StyleMixin"), require("../NativeValueMixin"), require("../ListenerMixin")]);

module.exports = type.build();

//# sourceMappingURL=../../../../map/src/Component/Type/Builder.map
