var Animated, Event, Factory, Immutable, NativeValue, Progress, Reaction, Void, assert, assertType, async, combine, emptyFunction, hook, isType, ref, ref1, steal, sync, validateTypes,
  slice = [].slice;

ref = require("type-utils"), isType = ref.isType, validateTypes = ref.validateTypes, assertType = ref.assertType, assert = ref.assert, Void = ref.Void;

ref1 = require("io"), sync = ref1.sync, async = ref1.async;

emptyFunction = require("emptyFunction");

Immutable = require("immutable");

Animated = require("Animated");

Progress = require("progress");

Reaction = require("reaction");

Factory = require("factory");

combine = require("combine");

Event = require("event");

steal = require("steal");

hook = require("hook");

module.exports = NativeValue = Factory("NativeValue", {
  initArguments: function(value, keyPath) {
    assertType(keyPath, [String, Void], "keyPath");
    return arguments;
  },
  getFromCache: function(value) {
    if (isKind(value, NativeValue)) {
      return value;
    } else {
      return void 0;
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
    velocity: {
      get: function() {
        var ref2, ref3;
        return (ref2 = this._animated) != null ? (ref3 = ref2._animation) != null ? ref3._lastVelocity : void 0 : void 0;
      }
    },
    isReactive: {
      get: function() {
        return this._reaction != null;
      }
    },
    reaction: {
      get: function() {
        return this._reaction;
      },
      set: function(newValue, oldValue) {
        var base;
        if (newValue == null) {
          return this._removeReaction();
        }
        if (isType(newValue, Function.Kind)) {
          newValue = Reaction.sync(newValue);
        }
        assertType(newValue, Reaction);
        if (this.isReactive) {
          this._removeReaction();
        } else {
          this._removeAnimated();
        }
        this._reaction = newValue;
        if ((base = this._reaction).keyPath == null) {
          base.keyPath = this.keyPath;
        }
        this._reactionListener = this._setValue.bind(this);
        this._reactionListener(newValue.value);
        return this._reaction.addListener(this._reactionListener);
      }
    }
  },
  initFrozenValues: function() {
    return {
      didSet: Event(),
      didAnimationEnd: Event()
    };
  },
  initValues: function(value, keyPath) {
    return {
      type: null,
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
    if (isType(value, Reaction)) {
      if (value.keyPath == null) {
        value.keyPath = keyPath;
      }
      return this.reaction = value;
    } else if (isType(value, Function.Kind)) {
      return this.reaction = Reaction.sync({
        keyPath: keyPath,
        get: value,
        autoStart: false
      });
    } else if (isType(value, Object)) {
      if (value.keyPath == null) {
        value.keyPath = keyPath;
      }
      if (value.autoStart == null) {
        value.autoStart = false;
      }
      return this.reaction = Reaction.sync(value);
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
  animate: function(config) {
    var animation, finished, listener, onEnd, onFinish, onUpdate;
    assert(!this.isReactive, {
      reason: "Cannot call 'animate' when 'isReactive' is true!",
      nativeValue: this
    });
    validateTypes(config, {
      onUpdate: [Function.Kind, Void],
      onEnd: [Function.Kind, Void],
      onFinish: [Function.Kind, Void]
    });
    this.stopAnimation();
    this._initAnimatedValue();
    onUpdate = steal(config, "onUpdate");
    if (onUpdate != null) {
      listener = this._animated.addListener((function(_this) {
        return function(result) {
          return onUpdate(result.value);
        };
      })(this));
    }
    onEnd = steal(config, "onEnd", emptyFunction);
    onFinish = steal(config, "onFinish", emptyFunction);
    this._fromValue = this._value;
    this._toValue = config.toValue;
    (Animated[this._getAnimatedMethod(config)](this._animated, config)).start();
    animation = this._animated._animation;
    if (animation == null) {
      if (onUpdate != null) {
        this._animated.removeListener(listener);
      }
      finished = (this._toValue == null) || (this._value === this._toValue);
      this._onAnimationEnd(finished, onFinish, onEnd);
      return;
    }
    this._animating = true;
    hook.after(animation, "__onEnd", (function(_this) {
      return function(_, result) {
        _this._animating = false;
        if (onUpdate != null) {
          _this._animated.removeListener(listener);
        }
        if (_this._toValue != null) {
          result.finished = _this._value === _this._toValue;
        }
        return _this._onAnimationEnd(result.finished, onFinish, onEnd);
      };
    })(this));
  },
  _onAnimationEnd: function(finished, onFinish, onEnd) {
    if (finished) {
      onFinish();
    }
    onEnd(finished);
    return this.didAnimationEnd.emit(finished);
  },
  finishAnimation: function() {
    if (!this.isAnimated) {
      return;
    }
    this._animated._value = this._toValue;
    this._value = this._animated.__getValue();
    return this._animated.stopAnimation();
  },
  stopAnimation: function() {
    if (!this.isAnimated) {
      return;
    }
    this._animated.stopAnimation();
  },
  getProgress: function(options) {
    var optionDefaults, value;
    assert(!this.isReactive, {
      reason: "Cannot call 'getProgress' when 'isReactive' is true!",
      nativeValue: this
    });
    optionDefaults = {
      at: this._value,
      to: this._toValue,
      from: this._fromValue != null ? this._fromValue : this._value
    };
    options = combine(optionDefaults, options);
    validateTypes(options, {
      at: Number,
      to: Number,
      from: Number,
      clamp: [Boolean, Void]
    });
    value = steal(options, "at");
    return Progress.fromValue(value, options);
  },
  setProgress: function(options) {
    var optionDefaults, progress;
    assert(!this.isReactive, {
      reason: "Cannot call 'setProgress' when 'isReactive' is true!",
      nativeValue: this
    });
    if (isType(options, Number)) {
      options = {
        progress: options
      };
    }
    optionDefaults = {
      from: this._fromValue,
      to: this._toValue
    };
    options = combine(optionDefaults, options);
    validateTypes(options, {
      progress: Number,
      from: Number,
      to: Number,
      clamp: [Boolean, Void]
    });
    progress = steal(options, "progress");
    if (this._inputRange != null) {
      progress = this._applyInputRange(progress);
    }
    if (this._easing != null) {
      progress = this._easing(progress);
    }
    return this.value = Progress.toValue(progress, options);
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
    if (this.type != null) {
      assertType(newValue, this.type);
    }
    this._value = newValue;
    return this.didSet.emit(newValue);
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
