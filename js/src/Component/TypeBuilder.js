var Reaction, Type, assertType, define, type;

assertType = require("type-utils").assertType;

Reaction = require("../Reaction/Reaction");

define = require("define");

Type = require("Type");

type = Type("ComponentModelBuilder");

type.inherits(Type.Builder);

type.initInstance(function() {
  return this.defineReactiveValues({
    view: null
  });
});

type.defineValues({
  _styles: null,
  _hasNativeValues: false,
  _hasListeners: false,
  _hasReactions: false
});

type.defineMethods({
  loadComponent: function(loadComponent) {
    assertType(loadComponent, Function);
    return this.initType(function(type) {
      var render;
      render = LazyVar(function() {
        return loadComponent.call(type.prototype);
      });
      return define(type.prototype, "render", function(props) {
        if (props) {
          if (ModelContext.current) {
            return props.__context = ModelContext.current;
          }
        }
      });
    });
  },
  createNativeValues: function(createNativeValues) {
    assertType(createNativeValues, Function);
    throw Error("Not yet implemented!");
  },
  createListeners: function(createListeners) {
    assertType(createListeners, Function);
    throw Error("Not yet implemented!");
  },
  defineReactions: function(reactions) {
    assertType(reactions, Object);
    if (!this._hasReactions) {
      this._hasReactions = true;
      this._initInstance(function() {
        return define(this, "__reactions", Object.create(null));
      });
    }
    return this._initInstance(function() {
      var createReaction, key, value;
      Reaction.inject.push("autoStart", true);
      for (key in reactions) {
        createReaction = reactions[key];
        assertType(createReaction, Function, key);
        value = createReaction.apply(this, args);
        if (value === void 0) {
          continue;
        }
        if (!isType(value, Reaction)) {
          value = Reaction.sync(value);
        }
        assert(this.__reactions[key] === void 0, {
          reason: "Conflicting reactions are both named '" + key + "'."
        });
        this.__reactions[key] = value;
        define(this, key, {
          value: value,
          enumerable: false
        });
      }
      return Reaction.inject.pop("autoStart");
    });
  },
  _startReactions: function() {
    throw Error("Not yet implemented!");
  },
  _stopReactions: function() {
    throw Error("Not yet implemented!");
  }
});

//# sourceMappingURL=../../../map/src/Component/TypeBuilder.map
