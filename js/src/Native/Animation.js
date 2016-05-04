var AnimatedValue, Progress, Type, hook, type;

AnimatedValue = require("Animated").AnimatedValue;

Progress = require("progress");

Type = require("Type");

hook = require("hook");

type = Type("Animation");

type.optionTypes = {
  animated: AnimatedValue,
  type: Function.Kind,
  config: Object,
  onUpdate: Function.Maybe,
  onEnd: Function.Maybe
};

type.defineProperties({
  isActive: {
    get: function() {
      return this._animation.__active;
    }
  },
  value: {
    get: function() {
      return this._animated.__getValue();
    }
  },
  fromValue: {
    get: function() {
      return this._fromValue;
    }
  },
  toValue: {
    get: function() {
      return this._toValue;
    }
  },
  progress: {
    get: function() {
      return Progress.fromValue(this.value, {
        fromValue: this._fromValue,
        toValue: this._toValue,
        clamp: true
      });
    }
  },
  velocity: {
    get: function() {
      var velocity;
      velocity = this._animation._curVelocity;
      if (isType(velocity, Number)) {
        return velocity;
      } else {
        return 0;
      }
    }
  }
});

type.defineFrozenValues({
  _animated: function(options) {
    return options.animated;
  },
  _animation: function(options) {
    return new options.type(options.config);
  }
});

type.defineValues({
  _fromValue: function() {
    return this.value;
  },
  _toValue: function(options) {
    return options.config.toValue;
  },
  _onUpdate: function(options) {
    return options.onUpdate;
  },
  _onEnd: function(options) {
    return options.onEnd;
  }
});

type.initInstance(function() {
  var onUpdate;
  onUpdate = this._animated.didSet((function(_this) {
    return function(result) {
      if (_this._onUpdate) {
        return _this._onUpdate(result);
      }
    };
  })(this));
  this._animated.animate(this._animation);
  if (!this.isActive) {
    if (onUpdate) {
      onUpdate.stop();
    }
    this._onEnd((this._toValue === void 0) || (this._toValue === this.value));
    return;
  }
  return hook.before(this._animation, "__onEnd", (function(_this) {
    return function(result) {
      if (onUpdate) {
        onUpdate.stop();
      }
      return _this._onEnd(result.finished);
    };
  })(this));
});

type.defineMethods({
  stop: function() {
    if (!this.isActive) {
      return;
    }
    this._animated.stopAnimation();
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

//# sourceMappingURL=../../../map/src/Native/Animation.map
