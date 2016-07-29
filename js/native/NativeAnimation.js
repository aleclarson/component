var AnimatedValue, Progress, Type, assertType, fromArgs, hook, isType, type;

AnimatedValue = require("Animated").AnimatedValue;

assertType = require("assertType");

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
      velocity = this._animation.velocity;
      if (!isType(velocity, Number)) {
        return 0;
      }
      return velocity;
    }
  }
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
      this._onEnd((this._toValue === void 0) || (this._toValue === this.value));
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
