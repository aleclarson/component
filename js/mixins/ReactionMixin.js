var Reaction, ValueMapper, assertType, baseImpl, createReaction, frozen, isType, sync, typeImpl;

frozen = require("Property").frozen;

ValueMapper = require("ValueMapper");

assertType = require("assertType");

Reaction = require("reaction");

isType = require("isType");

sync = require("sync");

module.exports = function(type) {
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.methods = {
  defineReactions: function(reactions) {
    var delegate, kind;
    assertType(reactions, Object.or(Function));
    delegate = this._delegate;
    if (!this.__hasReactions) {
      frozen.define(this, "__hasReactions", {
        value: true
      });
      kind = delegate._kind;
      if (!(kind && kind.prototype.__hasReactions)) {
        delegate._didBuild.push(baseImpl.didBuild);
        delegate._initInstance.push(baseImpl.initInstance);
        this._willMount.push(baseImpl.startReactions);
        this._willUnmount.push(baseImpl.stopReactions);
      }
    }
    reactions = ValueMapper({
      values: reactions,
      define: function(obj, key, value) {
        var reaction;
        if (value === void 0) {
          return;
        }
        reaction = createReaction(obj, key, value);
        obj.__reactions[key] = reaction;
        return frozen.define(obj, key, {
          get: function() {
            return reaction.value;
          }
        });
      }
    });
    delegate._initInstance.push(function(args) {
      return reactions.define(this, args);
    });
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

createReaction = function(obj, key, value) {
  var keyPath, options;
  keyPath = obj.constructor.name + "." + key;
  if (isType(value, Reaction)) {
    if (value.keyPath == null) {
      value.keyPath = keyPath;
    }
    return value;
  }
  if (isType(value, Function)) {
    options = {
      get: value,
      keyPath: keyPath
    };
  } else if (isType(value, Object)) {
    options = value;
    if (options.keyPath == null) {
      options.keyPath = keyPath;
    }
  }
  return Reaction.sync(options);
};

//# sourceMappingURL=map/ReactionMixin.map
