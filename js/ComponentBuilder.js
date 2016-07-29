var Builder, Component, ReactComponent, Type, assertType, type;

ReactComponent = require("ReactComponent");

assertType = require("assertType");

Builder = require("Builder");

Type = require("Type");

Component = require("./Component");

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

type.addMixins([require("./mixins/PropsMixin"), require("./mixins/LifecycleMixin"), require("./styles/StyleMixin"), require("./mixins/NativeValueMixin"), require("./mixins/ListenerMixin"), require("./mixins/ReactionMixin"), require("./mixins/GatedRenderMixin")]);

module.exports = type.build();

//# sourceMappingURL=map/ComponentBuilder.map
