var AnimatedValue, Progress, Type, assertType, hook, immediate, isType, type;

AnimatedValue = require("Animated").AnimatedValue;

assertType = require("assertType");

immediate = require("immediate");

Progress = require("progress");

isType = require("isType");

Type = require("Type");

hook = require("hook");

type = Type("NativeAnimation");

type.defineOptions({
  animated: AnimatedValue.isRequired,
  onUpdate: Function.Maybe,
  onEnd: Function.Maybe
});

type.defineFrozenValues(function(options) {
  return {
    _animated: options.animated
  };
});

type.defineValues(function(options) {
  return {
    _onUpdate: options.onUpdate,
    _onEnd: options.onEnd,
    _animation: null
  };
});

type.defineGetters({
  isActive: function() {
    var anim;
    if (anim = this._animation) {
      return anim.isActive;
    } else {
      return false;
    }
  },
  value: function() {
    var anim;
    if (anim = this._animation) {
      return anim.value;
    } else {
      return null;
    }
  },
  startValue: function() {
    var anim;
    if (anim = this._animation) {
      return anim.startValue;
    } else {
      return null;
    }
  },
  endValue: function() {
    var anim;
    if (anim = this._animation) {
      return anim.endValue;
    } else {
      return null;
    }
  },
  progress: function() {
    var anim;
    if (anim = this._animation) {
      return anim.progress;
    } else {
      return 0;
    }
  },
  velocity: function() {
    var anim;
    if (anim = this._animation) {
      if (!isType(anim.velocity, Number)) {
        return null;
      }
      return anim.velocity;
    }
    return 0;
  }
});

type.defineMethods({
  start: function(config) {
    var onUpdate;
    assertType(config, Object);
    assertType(config.type, Function.Kind);
    if (this._onUpdate) {
      onUpdate = this._animated.didSet(this._onUpdate).start();
    }
    this._animation = this._animated.animate(config.type(config));
    if (!this.isActive) {
      onUpdate && onUpdate.detach();
      immediate((function(_this) {
        return function() {
          return _this._onEnd(true);
        };
      })(this));
      return;
    }
    hook.before(this._animation, "_onEnd", (function(_this) {
      return function(finished) {
        onUpdate && onUpdate.detach();
        return _this._onEnd(finished);
      };
    })(this));
  },
  stop: function() {
    if (!this.isActive) {
      return;
    }
    this._animated.stopAnimation();
    this._animation = null;
  },
  finish: function() {
    if (!this.isActive) {
      return;
    }
    if (this._toValue !== void 0) {
      this._animated.setValue(this._toValue);
    } else {
      this._animated.stopAnimation();
    }
  }
});

module.exports = type.build();

//# sourceMappingURL=map/NativeAnimation.map
