var Builder, ReactComponent, Type, assertType, type;

ReactComponent = require("ReactComponent");

assertType = require("assertType");

Builder = require("Builder");

Type = require("Type");

type = Type("modx_ComponentBuilder");

type.inherits(Builder);

type.trace();

type.initInstance(function() {
  return this._defaultKind = ReactComponent;
});

type.defineGetters({
  _delegate: function() {
    return this;
  }
});

type.overrideMethods({
  _defaultBaseCreator: function(args) {
    var instance;
    instance = this.__super(arguments);
    ReactComponent.apply(instance, args);
    return instance;
  }
});

type.addMixins([require("./mixins/PropsMixin"), require("./mixins/LifecycleMixin"), require("./mixins/StyleMixin"), require("./mixins/NativeValueMixin"), require("./mixins/ListenerMixin"), require("./mixins/ReactionMixin"), require("./mixins/GatedRenderMixin")]);

module.exports = type.build();

//# sourceMappingURL=map/ComponentBuilder.map
