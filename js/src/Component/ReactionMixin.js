var Property, Random, Reaction, assert, assertType, define, frozen, hasReactions, isType, typeImpl;

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
    var delegate, kind, phaseId;
    assertType(reactions, Object);
    delegate = this._delegate;
    kind = delegate._kind;
    if (!this[hasReactions]) {
      frozen.define(this, hasReactions, true);
      if (!(kind && kind.prototype[hasReactions])) {
        this._didBuild(function(type) {
          return frozen.define(type.prototype, hasReactions, true);
        });
        delegate._initInstance.push(function() {
          return frozen.define(this, "__reactionKeys", Object.create(null));
        });
      }
    }
    phaseId = Random.id();
    delegate._initInstance.push(function(args) {
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
    });
    this._willMount.push(function() {
      var i, key, len, reaction, ref;
      delegate = this._delegate;
      ref = delegate.__reactionKeys[phaseId];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        reaction = delegate[key];
        guard(function() {
          return reaction.start();
        }).fail(function(error) {
          return throwFailure(error, {
            key: key,
            reaction: reaction,
            phaseId: phaseId,
            delegate: delegate
          });
        });
      }
    });
    this._willUnmount.push(function() {
      var key, reaction, ref;
      delegate = this._delegate;
      ref = delegate.__reactionKeys[phaseId];
      for (key in ref) {
        reaction = ref[key];
        delegate[key].stop();
      }
    });
  }
};

//# sourceMappingURL=../../../map/src/Component/ReactionMixin.map
