var Reaction, gatedRender, hook, instanceReactions, instanceValues, shift, typeMethods, typePhases, typeValues;

Reaction = require("reaction");

hook = require("hook");

shift = Array.prototype.shift;

module.exports = function(type) {
  type.defineValues(typeValues);
  return type.defineMethods(typeMethods);
};

typeValues = {
  _isRenderPrevented: null
};

typeMethods = {
  isRenderPrevented: function(isRenderPrevented) {
    assertType(isRenderPrevented, Function);
    assert(!this._isRenderPrevented, "'isRenderPrevented' is already defined!");
    this._isRenderPrevented = isRenderPrevented;
    this._viewType.defineValues(instanceValues);
    this._viewType.defineReactions(instanceReactions);
    this._viewType.defineMethods({
      isRenderPrevented: isRenderPrevented
    });
    this.willBuild(typePhases.build);
  }
};

typePhases = {
  willBuild: function() {
    hook(this, "_render", gatedRender);
    return hook(this, "_shouldUpdate", gatedRender);
  }
};

instanceValues = {
  needsRender: false
};

instanceReactions = {
  shouldRender: function() {
    return {
      get: (function(_this) {
        return function() {
          return !_this.isRenderPrevented.call(_this.context);
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
          } catch (_error) {}
        };
      })(this)
    };
  }
};

gatedRender = function() {
  var orig;
  if (this.view.shouldRender.value) {
    orig = shift.call(arguments);
    return orig.apply(this, arguments);
  }
  this.needsRender = true;
  return false;
};

//# sourceMappingURL=../../../../map/src/Component/mixins/GatedRender.map
