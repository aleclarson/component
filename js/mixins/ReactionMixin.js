var Random, Reaction, assert, assertType, baseImpl, frozen, hasReactions, isType, sync, typeImpl;

frozen = require("Property").frozen;

assertType = require("assertType");

Reaction = require("reaction");

Random = require("random");

isType = require("isType");

assert = require("assert");

sync = require("sync");

hasReactions = Symbol("Component.hasReactions");

module.exports = function(type) {
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.methods = {
  defineReactions: function(reactions) {
    var createReactions, delegate, kind, phaseId, startReactions, stopReactions;
    assertType(reactions, Object);
    delegate = this._delegate;
    if (!this[hasReactions]) {
      frozen.define(this, hasReactions, {
        value: true
      });
      kind = delegate._kind;
      if (!(kind && kind.prototype[hasReactions])) {
        delegate._didBuild.push(baseImpl.didBuild);
        delegate._initInstance.push(baseImpl.initInstance);
      }
    }
    phaseId = Random.id();
    createReactions = function(args) {
      var getOptions, key, keys, options, reaction;
      keys = [];
      for (key in reactions) {
        getOptions = reactions[key];
        assertType(getOptions, Function, key);
        options = getOptions.apply(this, args);
        if (options === void 0) {
          continue;
        }
        keys.push(key);
        reaction = isType(options, Reaction) ? options : Reaction.sync(options);
        frozen.define(this, key, {
          get: function() {
            return reaction.value;
          }
        });
      }
      this.__reactions[key] = reaction;
    };
    delegate._initInstance.push(createReactions);
    startReactions = function() {
      sync.each(this.__reactions, function(reaction) {
        return reaction.start();
      });
    };
    this._willMount.push(startReactions);
    stopReactions = function() {
      sync.each(this.__reactions, function(reaction) {
        return reaction.stop();
      });
    };
    this._willUnmount.push(stopReactions);
  }
};

baseImpl = {};

baseImpl.didBuild = function(type) {
  return frozen.define(type.prototype, hasReactions, {
    value: true
  });
};

baseImpl.initInstance = function() {
  return frozen.define(this, "__reactions", {
    value: Object.create(null)
  });
};

//# sourceMappingURL=map/ReactionMixin.map
