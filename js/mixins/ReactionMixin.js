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
        this._willMount.push(baseImpl.startReactions);
        this._willUnmount.push(baseImpl.stopReactions);
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
        obj.__reactions[key] = reaction;
        return frozen.define(obj, key, {
          get: function() {
            return reaction.value;
          }
        });
      }
    });
    defineReactions = function() {
      return reactions.define(this);
    };
    delegate._initPhases.push(defineReactions);
  }
};

baseImpl = {};

baseImpl.didBuild = function(type) {
  return frozen.define(type.prototype, "__hasReactions", {
    value: true
  });
};

baseImpl.initInstance = function() {
  return frozen.define(this, "__reactions", {
    value: Object.create(null)
  });
};

baseImpl.stopReactions = function() {
  var key, reaction, ref;
  ref = this.__reactions;
  for (key in ref) {
    reaction = ref[key];
    reaction.stop();
  }
};

baseImpl.startReactions = function() {
  var key, reaction, ref;
  ref = this.__reactions;
  for (key in ref) {
    reaction = ref[key];
    reaction.start();
  }
};

getReaction = (function() {
  var bindClone, createOptions;
  bindClone = function(values, context) {
    var clone, key, value;
    clone = {};
    for (key in values) {
      value = values[key];
      clone[key] = isType(value, Function) ? bind.func(value, context) : value;
    }
    return clone;
  };
  createOptions = function(arg, context) {
    if (isType(arg, Object)) {
      return bindClone(arg, context);
    }
    if (isType(arg, Function)) {
      return {
        get: bind.func(arg, context)
      };
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
    options = createOptions(value, obj);
    if (options.keyPath == null) {
      options.keyPath = obj.constructor.name + "." + key;
    }
    return Reaction.sync(options);
  };
})();

//# sourceMappingURL=map/ReactionMixin.map
