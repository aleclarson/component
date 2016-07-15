var Property, Random, Reaction, assert, assertType, baseImpl, define, frozen, hasReactions, isType, typeImpl;

assertType = require("assertType");

Property = require("Property");

Reaction = require("reaction");

Random = require("random");

isType = require("isType");

assert = require("assert");

define = require("define");

hasReactions = Symbol("Component.hasReactions");

frozen = Property({
  frozen: true
});

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
      frozen.define(this, hasReactions, true);
      kind = delegate._kind;
      if (!(kind && kind.prototype[hasReactions])) {
        delegate._didBuild.push(baseImpl.didBuild);
        delegate._initInstance.push(baseImpl.initInstance);
      }
    }
    phaseId = Random.id();
    createReactions = function(args) {
      var key, keys, options, value;
      keys = [];
      for (key in reactions) {
        value = reactions[key];
        assertType(value, Function, key);
        options = value.apply(this, args);
        if (options === void 0) {
          continue;
        }
        keys.push(key);
        value = isType(options, Reaction) ? options : Reaction.sync(options);
        frozen.define(this, key, value);
      }
      this.__reactionKeys[phaseId] = keys;
    };
    delegate._initInstance.push(createReactions);
    startReactions = function() {
      var i, key, len, ref;
      ref = this.__reactionKeys[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        this[key].start();
      }
    };
    this._willMount.push(startReactions);
    stopReactions = function() {
      var i, key, len, ref;
      ref = this.__reactionKeys[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        this[key].stop();
      }
    };
    this._willUnmount.push(stopReactions);
  }
};

baseImpl = {};

baseImpl.didBuild = function(type) {
  return frozen.define(type.prototype, hasReactions, true);
};

baseImpl.initInstance = function() {
  return frozen.define(this, "__reactionKeys", Object.create(null));
};

//# sourceMappingURL=map/ReactionMixin.map
