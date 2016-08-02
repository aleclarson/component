var AnimatedValue, Progress, Type, assertType, fromArgs, hook, immediate, isType, type;

AnimatedValue = require("Animated").AnimatedValue;

assertType = require("assertType");

immediate = require("immediate");

fromArgs = require("fromArgs");

Progress = require("progress");

isType = require("isType");

Type = require("Type");

hook = require("hook");

type = Type("NativeAnimation");

type.defineOptions({
  animated: AnimatedValue.isRequired,
  config: Object,
  onUpdate: Function.Maybe,
  onEnd: Function.Maybe
});

type.defineFrozenValues({
  _animated: fromArgs("animated")
});

type.defineValues({
  _fromValue: function() {
    return this.value;
  },
  _toValue: fromArgs("config.toValue"),
  _onUpdate: fromArgs("onUpdate"),
  _onEnd: fromArgs("onEnd"),
  _animation: null
});

type.defineGetters({
  isActive: function() {
    return this._animation.__active;
  },
  value: function() {
    return this._animated.__getValue();
  },
  fromValue: function() {
    return this._fromValue;
  },
  toValue: function() {
    return this._toValue;
  },
  progress: function() {
    return Progress.fromValue(this.value, {
      fromValue: this._fromValue,
      toValue: this._toValue,
      clamp: true
    });
  },
  velocity: function() {
    var velocity;
    velocity = this._animation.velocity;
    if (!isType(velocity, Number)) {
      return 0;
    }
    return velocity;
  }
});

type.defineMethods({
  start: function(config) {
    var onUpdate;
    assertType(config, Object);
    assertType(config.type, Function.Kind);
    if (this._onUpdate) {
      onUpdate = this._onUpdate && this._animated.didSet(this._onUpdate);
      onUpdate.start();
    }
    this._animation = config.type(config);
    this._animated.animate(this._animation);
    if (!this.isActive) {
      onUpdate && onUpdate.detach();
      immediate((function(_this) {
        return function() {
          return _this._onEnd(true);
        };
      })(this));
      return;
    }
    hook.before(this._animation, "__onEnd", (function(_this) {
      return function(result) {
        onUpdate && onUpdate.detach();
        return _this._onEnd(result.finished);
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
