var Builder, Component, ReactComponent, Type, type;

ReactComponent = require("ReactComponent");

Builder = require("Builder");

Type = require("Type");

Component = require(".");

type = Type("ComponentBuilder");

type.inherits(Builder);

type.initInstance(function() {
  return this._willBuild.push(function() {
    return this._kind != null ? this._kind : this._kind = ReactComponent;
  });
});

type.overrideMethods({
  inherits: function() {
    throw Error("Cannot call 'inherits' as a ComponentBuilder!");
  },
  createInstance: function() {
    throw Error("Cannot call 'createInstance' as a ComponentBuilder!");
  },
  __createBaseObject: function(args) {
    var instance;
    instance = Object.create(ReactComponent.prototype);
    ReactComponent.apply(instance, args);
    return instance;
  }
});

type.addMixins([require("./PropsMixin"), require("./LifecycleMixin"), require("./StyleMixin"), require("./NativeValueMixin"), require("./ListenerMixin"), require("./GatedRenderMixin")]);

module.exports = type.build();

//# sourceMappingURL=../../../map/src/Component/Builder.map
