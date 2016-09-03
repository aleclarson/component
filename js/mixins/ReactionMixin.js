var Reaction, ValueMapper, assertType, baseImpl, bind, frozen, getReaction, isType, sync, typeImpl;

frozen = require("Property").frozen;

ValueMapper = require("ValueMapper");

assertType = require("assertType");

Reaction = require("Reaction");

isType = require("isType");

bind = require("bind");

sync = require("sync");

module.exports = function(type) {
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.methods = {
  defineReactions: function(reactions) {
    var defineReactions, delegate, kind;
    assertType(reactions, Object.or(Function));
    delegate = this._delegate;
    if (!this.__hasReactions) {
      frozen.define(this, "__hasReactions", {
        value: true
      });
      kind = delegate._kind;
      if (!(kind && kind.prototype.__hasReactions)) {
        delegate.didBuild(baseImpl.didBuild);
        delegate.initInstance(baseImpl.initInstance);
      }
    }
    if (isType(reactions, Object)) {
      reactions = sync.map(reactions, function(value) {
        if (isType(value, Function)) {
          return function() {
            return value;
          };
        }
        return value;
      });
    }
    reactions = ValueMapper({
      values: reactions,
      define: function(obj, key, value) {
        var reaction;
        if (value === void 0) {
          return;
        }
        reaction = getReaction(obj, key, value);
        frozen.define(obj, key, {
          value: reaction
        });
        return reaction.start();
      }
    });
    defineReactions = function() {
      return reactions.define(this);
    };
    delegate._phases.init.push(defineReactions);
  }
};

baseImpl = {
  didBuild: function(type) {
    return frozen.define(type.prototype, "__hasReactions", {
      value: true
    });
  },
  initInstance: function() {
    return frozen.define(this, "__reactions", {
      value: Object.create(null)
    });
  }
};

getReaction = (function() {
  var createOptions;
  createOptions = function(arg, context) {
    if (isType(arg, Function)) {
      return;
    }
    throw TypeError("Expected an Object or Function!");
  };
  return getReaction = function(obj, key, value) {
    var options;
    if (isType(value, Reaction)) {
      if (value.keyPath == null) {
        value.keyPath = obj.constructor.name + "." + key;
      }
      return value;
    }
    if (isType(value, Function)) {
      options = {
        get: bind.func(value, obj)
      };
    } else {
      options = value;
    }
    if (options.keyPath == null) {
      options.keyPath = obj.constructor.name + "." + key;
    }
    return Reaction(options);
  };
})();

//# sourceMappingURL=map/ReactionMixin.map
