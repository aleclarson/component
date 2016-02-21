var Animated, Factory, Immutable, Listenable, NativeValue, Reaction, Void, assert, assertType, async, combine, emptyFunction, isType, ref, ref1, reportFailure, steal, sync, validateTypes,
  slice = [].slice;

ref = require("type-utils"), isType = ref.isType, validateTypes = ref.validateTypes, assertType = ref.assertType, assert = ref.assert, Void = ref.Void;

ref1 = require("io"), sync = ref1.sync, async = ref1.async;

reportFailure = require("report-failure");

emptyFunction = require("emptyFunction");

Listenable = require("listenable");

Immutable = require("immutable");

Animated = require("Animated");

Reaction = require("reaction");

Factory = require("factory");

combine = require("combine");

steal = require("steal");

module.exports = NativeValue = Factory("NativeValue", {
  initArguments: function(value, keyPath) {
    assertType(keyPath, [String, Void], "keyPath");
    return arguments;
  },
  create: function(value) {
    if (isKind(value, NativeValue)) {
      return value;
    } else {
      return {};
    }
  },
  customValues: {
    keyPath: {
      get: function() {
        return this._keyPath;
      },
      set: function(keyPath) {
        var ref2;
        this._keyPath = keyPath;
        return (ref2 = this._reaction) != null ? ref2.keyPath = keyPath : void 0;
      }
    },
    value: {
      get: function() {
        return this._value;
      },
      set: function(newValue) {
        assert(!this.isReactive, {
          reason: "Cannot set 'value' when 'isReactive' is true!",
          nativeValue: this
        });
        if (this.isAnimated) {
          return this._animated.setValue(newValue);
        } else {
          return this._setValue(newValue);
        }
      }
    },
    getValue: {
      lazy: function() {
        return (function(_this) {
          return function() {
            return _this._value;
          };
        })(this);
      }
    },
    toValue: {
      get: function() {
        var ref2, ref3;
        return ((ref2 = this._animated) != null ? (ref3 = ref2._animation) != null ? ref3._toValue : void 0 : void 0) || this._value;
      }
    },
    progress: {
      get: function() {
        return this.getProgress();
      },
      set: function(progress) {
        return this.setProgress(progress);
      }
    },
    isAnimated: {
      get: function() {
        return this._animated != null;
      }
    },
    isAnimating: {
      get: function() {
        return this._animating;
      }
    },
    isReactive: {
      get: function() {
        return this._reaction != null;
      }
    }
  },
  initValues: function(value, keyPath) {
    return {
      _keyPath: keyPath,
      _inputRange: null,
      _easing: null,
      _reaction: null,
      _reactionListener: null,
      _animated: null,
      _animatedListener: null
    };
  },
  initReactiveValues: function() {
    return {
      _animating: false,
      _fromValue: null,
      _toValue: null,
      _value: null
    };
  },
  init: function(value, keyPath) {
    Listenable(this, {
      eventNames: true
    });
    if (isType(value, Reaction)) {
      if (value.keyPath == null) {
        value.keyPath = keyPath;
      }
      return this.setReaction(value);
    } else if (isType(value, Function.Kind)) {
      return this.setReaction(Reaction.sync({
        keyPath: keyPath,
        get: value,
        autoStart: false
      }));
    } else if (isType(value, Object)) {
      if (value.keyPath == null) {
        value.keyPath = keyPath;
      }
      if (value.autoStart == null) {
        value.autoStart = false;
      }
      return this.setReaction(Reaction.sync(value));
    } else {
      return this.value = value;
    }
  },
  detach: function() {},
  absorb: function() {
    var nativeValues, newValue;
    nativeValues = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    newValue = this.value;
    sync.each(nativeValues, function(nativeValue) {
      newValue += nativeValue.value;
      return nativeValue.value = 0;
    });
    return this.value = newValue;
  },
  setReaction: function(reaction) {
    var base;
    if (reaction == null) {
      return this._removeReaction();
    }
    assertType(reaction, Reaction);
    if (this.isReactive) {
      this._removeReaction();
    } else {
      this._removeAnimated();
    }
    this._reaction = reaction;
    if ((base = this._reaction).keyPath == null) {
      base.keyPath = this.keyPath;
    }
    this._reactionListener = this._setValue.bind(this);
    this._reactionListener(reaction.value);
    return this._reaction.addListener(this._reactionListener);
  },
  animate: function(config) {
    var animation, effect, finished, method, onEnd, onFinish;
    assert(!this.isReactive, {
      reason: "Cannot call 'animate' when 'isReactive' is true!",
      nativeValue: this
    });
    this._initAnimatedValue();
    if (config.effect != null) {
      effect = steal(config, "effect");
      combine(config, effect);
    }
    this._fromValue = this._value;
    this._toValue = config.toValue;
    onEnd = steal(config, "onEnd", emptyFunction);
    assertType(onEnd, Function, {
      config: config,
      onEnd: onEnd,
      emptyFunction: emptyFunction,
      key: "onEnd"
    });
    onFinish = steal(config, "onFinish", emptyFunction);
    assertType(onFinish, Function, {
      config: config,
      key: "onFinish"
    });
    method = this._getAnimatedMethod(config);
    animation = Animated[method](this._animated, config);
    animation.start();
    if (this._animated._animation != null) {
      this._animating = true;
      this.onAnimationEnd((function(_this) {
        return function(finished) {
          _this._animating = false;
          if (finished) {
            onFinish();
          }
          return onEnd(finished);
        };
      })(this));
    } else {
      finished = this._value === this._toValue;
      if (finished) {
        onFinish();
      }
      onEnd(finished);
    }
  },
  stopAnimation: function(callback) {
    if (this._animated == null) {
      if (typeof callback === "function") {
        callback(this._value);
      }
    } else if (this._animated._animation != null) {
      this._animated.stopAnimation(callback);
    } else {
      if (typeof callback === "function") {
        callback(this._animated.__getValue());
      }
    }
  },
  onAnimationUpdate: function(callback) {
    var animated, id;
    assertType(callback, Function);
    animated = this._animated;
    if ((animated != null ? animated._animation : void 0) == null) {
      return;
    }
    id = animated.addListener(function(result) {
      return callback(result.value);
    });
    this.onAnimationEnd(function() {
      return animated.removeListener(id);
    });
  },
  onAnimationEnd: function(callback) {
    var animation, onEnd, ref2;
    assertType(callback, Function);
    animation = (ref2 = this._animated) != null ? ref2._animation : void 0;
    if (animation == null) {
      return callback(true);
    }
    onEnd = animation.__onEnd;
    animation.__onEnd = function(result) {
      onEnd.call(this, result);
      return callback(result.finished);
    };
  },
  onAnimationFinish: function(callback) {
    return this.onAnimationEnd(function(finished) {
      if (finished) {
        return callback();
      }
    });
  },
  getProgress: function(config) {
    var at, clamp, from, progress, to;
    if (config == null) {
      config = {};
    }
    assert(!this.isReactive, {
      reason: "Cannot call 'getProgress' when 'isReactive' is true!",
      nativeValue: this
    });
    assertType(config, Object);
    validateTypes(config, {
      at: [Number, Void],
      to: [Number, Void],
      from: [Number, Void],
      clamp: [Boolean, Void]
    });
    at = config.at, to = config.to, from = config.from, clamp = config.clamp;
    if (at == null) {
      at = this._value;
    }
    if (to == null) {
      to = this._toValue;
    }
    if (from == null) {
      from = this._fromValue;
    }
    if (from == null) {
      from = this._value;
    }
    assert(to != null);
    assert(from != null);
    progress = to === from ? 1 : (at - from) / (to - from);
    if (clamp) {
      return Math.max(0, Math.min(1, progress));
    } else {
      return progress;
    }
  },
  setProgress: function(config) {
    var from, progress, to;
    assert(!this.isReactive, {
      reason: "Cannot call 'setProgress' when 'isReactive' is true!",
      nativeValue: this
    });
    if (isType(config, Number)) {
      config = {
        progress: config
      };
    }
    if (config.from == null) {
      config.from = this._fromValue;
    }
    if (config.to == null) {
      config.to = this._toValue;
    }
    validateTypes(config, {
      progress: Number,
      from: Number,
      to: Number
    });
    progress = config.progress, from = config.from, to = config.to;
    if (this._inputRange != null) {
      progress = this._applyInputRange(progress);
    }
    if (this._easing != null) {
      progress = this._easing(progress);
    }
    assertType(progress, Number);
    return this.value = from + progress * (to - from);
  },
  willProgress: function(config) {
    var easing, from, to, within;
    assert(!this.isReactive, {
      reason: "Cannot call 'willProgress' when 'isReactive' is true!",
      nativeValue: this
    });
    validateTypes(config, {
      from: [Number, Void],
      to: Number,
      within: [Array, Void],
      easing: [Function, Void]
    });
    to = config.to, from = config.from, within = config.within, easing = config.easing;
    if (within != null) {
      assert(within.length === 2);
      assert(within[0] <= within[1]);
    }
    this._inputRange = within;
    this._easing = easing;
    this._fromValue = from != null ? from : from = this._value;
    return this._toValue = to;
  },
  _setValue: function(newValue) {
    this._value = newValue;
    return this._emit("didSet", newValue);
  },
  _applyInputRange: function(value) {
    var max, min, ref2;
    assert(this._inputRange, Array);
    ref2 = this._inputRange, min = ref2[0], max = ref2[1];
    value = Math.max(min, Math.min(max, value));
    return (value - min) / (max - min);
  },
  _initAnimatedValue: function() {
    var listener;
    if (this._animated != null) {
      return;
    }
    this._animated = new Animated.Value(this._value);
    listener = (function(_this) {
      return function(arg) {
        var value;
        value = arg.value;
        return _this._setValue(value);
      };
    })(this);
    return this._animatedListener = this._animated.addListener(listener);
  },
  _getAnimatedMethod: function(config) {
    if (config.duration != null) {
      return "timing";
    } else if (config.deceleration != null) {
      return "decay";
    } else if (((config.bounciness != null) || (config.speed != null)) || ((config.tension != null) || (config.friction != null))) {
      return "spring";
    } else {
      throw Error("Unrecognized animation configuration");
    }
  },
  _removeReaction: function() {
    if (!this.isReactive) {
      return;
    }
    this._reaction.removeListener(this._reactionListener);
    this._reactionListener = null;
    this._reaction = null;
  },
  _removeAnimated: function() {
    if (!this.isAnimated) {
      return;
    }
    this._animated.stopAnimation();
    this._animated.removeListener(this._animatedListener);
    this._animatedListener = null;
    this._animated = null;
  }
});

//# sourceMappingURL=../../map/src/NativeValue.map
