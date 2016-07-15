var Builder, Component, ReactComponent, Type, assertType, type;

ReactComponent = require("ReactComponent");

assertType = require("assertType");

Builder = require("Builder");

Type = require("Type");

Component = require(".");

type = Type("ComponentBuilder");

type.inherits(Builder);

type._initInstance.unshift(function() {
  this._tracer.trace();
  return this._willBuild.push(function() {
    return this._kind != null ? this._kind : this._kind = ReactComponent;
  });
});

type.definePrototype({
  _delegate: {
    get: function() {
      return this;
    }
  }
});

type.overrideMethods({
  __createBaseObject: function(args) {
    var instance;
    instance = Builder.prototype.__createBaseObject.apply(null, arguments);
    ReactComponent.apply(instance, args);
    return instance;
  }
});

type.addMixins([require("./PropsMixin"), require("./LifecycleMixin"), require("./StyleMap/Mixin"), require("./NativeValueMixin"), require("./ListenerMixin"), require("./ReactionMixin"), require("./GatedRenderMixin")]);

module.exports = type.build();

//# sourceMappingURL=map/Builder.map
