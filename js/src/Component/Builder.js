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
    if (this._kind == null) {
      this._kind = ReactComponent;
    }
    return this._initInstance.push(function() {
      var inst;
      return inst = this;
    });
  });
});

type.definePrototype({
  _delegate: {
    get: function() {
      return this;
    }
  }
});

type.defineStatics({
  _elementType: {
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

type.addMixins([require("./PropsMixin"), require("./LifecycleMixin"), require("./StylesMixin"), require("./NativeValueMixin"), require("./ListenerMixin"), require("./ReactionMixin"), require("./GatedRenderMixin")]);

module.exports = type.build();

//# sourceMappingURL=../../../map/src/Component/Builder.map
