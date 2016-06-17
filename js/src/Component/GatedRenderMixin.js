var Reaction, assert, assertType, hook, instImpl, shift, typeImpl;

require("isDev");

assertType = require("assertType");

Reaction = require("reaction");

assert = require("assert");

hook = require("hook");

shift = Array.prototype.shift;

module.exports = function(type) {
  type.defineValues(typeImpl.values);
  return type.defineMethods(typeImpl.methods);
};

typeImpl = {};

typeImpl.values = {
  _isRenderPrevented: null
};

typeImpl.methods = {
  isRenderPrevented: function(func) {
    var delegate;
    assert(!this._isRenderPrevented, "'isRenderPrevented' is already defined!");
    assertType(func, Function);
    this._isRenderPrevented = func;
    this._willBuild.push(typeImpl.willBuild);
    delegate = this._delegate;
    delegate.defineValues(instImpl.values);
    delegate.defineReactions(instImpl.reactions);
    delegate.defineMethods({
      isRenderPrevented: func
    });
  }
};

typeImpl.willBuild = function() {
  hook(this, "_render", typeImpl.gatedRender);
  return hook(this, "_shouldUpdate", typeImpl.gatedRender);
};

typeImpl.gatedRender = function() {
  var orig;
  if (this.view.shouldRender.value) {
    orig = shift.call(arguments);
    return orig.call(this);
  }
  this.needsRender = true;
  return false;
};

instImpl = {};

instImpl.values = {
  needsRender: false
};

instImpl.reactions = {
  shouldRender: function() {
    return {
      get: (function(_this) {
        return function() {
          return !_this.isRenderPrevented();
        };
      })(this),
      didSet: (function(_this) {
        return function(shouldRender) {
          if (!(_this.needsRender && shouldRender)) {
            return;
          }
          _this.needsRender = false;
          try {
            return _this.forceUpdate();
          } catch (error) {}
        };
      })(this)
    };
  }
};

//# sourceMappingURL=../../../map/src/Component/GatedRenderMixin.map
