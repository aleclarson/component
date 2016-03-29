var Animated, Event, Factory, Immutable, Maybe, NativeValue, Progress, Reaction, assert, assertType, combine, emptyFunction, hook, isDev, isType, ref, steal, sync, validateTypes,
  slice = [].slice;

ref = require("type-utils"), isType = ref.isType, validateTypes = ref.validateTypes, assertType = ref.assertType, assert = ref.assert, Maybe = ref.Maybe;

emptyFunction = require("emptyFunction");

Immutable = require("immutable");

Animated = require("Animated");

Progress = require("progress");

Reaction = require("reaction");

Factory = require("factory");

combine = require("combine");

Event = require("event");

steal = require("steal");

isDev = require("isDev");

sync = require("sync");

hook = require("hook");

module.exports = NativeValue = Factory("NativeValue", {
  initArguments: function(value, keyPath) {
    assertType(keyPath, String.Maybe, "keyPath");
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
        var ref1;
        this._keyPath = keyPath;
        return (ref1 = this._reaction) != null ? ref1.keyPath = keyPath : void 0;
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
        var ref1, ref2;
        return ((ref1 = this._animated) != null ? (ref2 = ref1._animation) != null ? ref2._toValue : void 0 : void 0) || this._value;
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
        var ref1, ref2;
        return (ref1 = this._animated) != null ? (ref2 = ref1._animation) != null ? ref2._lastVelocity : void 0 : void 0;
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
        if (newValue === oldValue) {
          return;
        }
        return this._attachReaction(newValue);
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
      _keyPath: keyPath,
      _inputRange: null,
      _easing: null,
      _reaction: null,
      _reactionListener: null,
      _animated: null,
      _animatedListener: null,
      _animateStackTrace: null
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
        get: value
      });
    } else if (isType(value, Object)) {
      if (value.keyPath == null) {
        value.keyPath = keyPath;
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
    var animation, finished, listener, onEnd, onFinish, onUpdate, type;
    assert(!this.isReactive, {
      reason: "Cannot call 'animate' when 'isReactive' is true!",
      nativeValue: this
    });
    validateTypes(config, {
      onUpdate: Maybe(Function.Kind),
      onEnd: Maybe(Function.Kind),
      onFinish: Maybe(Function.Kind)
    });
    this.stopAnimation();
    this._attachAnimated();
    if (isDev) {
      this._animateStackTrace = Error();
    }
    onUpdate = steal(config, "onUpdate");
    if (onUpdate) {
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
    type = this._detectAnimationType(config);
    animation = Animated[type](this._animated, config);
    animation.start();
    animation = this._animated._animation;
    if (!animation) {
      if (onUpdate) {
        this._animated.removeListener(listener);
      }
      finished = (this._toValue === void 0) || (this._toValue === this._value);
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
      clamp: Boolean.Maybe
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
      clamp: Boolean.Maybe
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
      from: Number.Maybe,
      to: Number,
      within: Array.Maybe,
      easing: Function.Maybe
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
    if (this.type !== void 0) {
      assertType(newValue, this.type, {
        stack: this._animateStack
      });
    }
    if (this._value === newValue) {
      return;
    }
    this._value = newValue;
    return this.didSet.emit(newValue);
  },
  _applyInputRange: function(value) {
    var max, min, ref1;
    assert(this._inputRange, Array);
    ref1 = this._inputRange, min = ref1[0], max = ref1[1];
    value = Math.max(min, Math.min(max, value));
    return (value - min) / (max - min);
  },
  _attachReaction: function(reaction) {
    var base;
    if (!reaction) {
      return this._detachReaction();
    }
    if (isType(reaction, [Object, Function.Kind])) {
      reaction = Reaction.sync(reaction);
    }
    assertType(reaction, Reaction);
    if (this.isReactive) {
      this._detachReaction();
    } else {
      this._detachAnimated();
    }
    this._reaction = reaction;
    if ((base = this._reaction).keyPath == null) {
      base.keyPath = this.keyPath;
    }
    this._reactionListener = this._reaction.didSet((function(_this) {
      return function(newValue) {
        return _this._setValue(newValue);
      };
    })(this));
    return this._setValue(reaction.value);
  },
  _attachAnimated: function() {
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
  _detectAnimationType: function(config) {
    if (config.duration !== void 0) {
      return "timing";
    }
    if (config.deceleration !== void 0) {
      return "decay";
    }
    if ((config.speed !== void 0) || (config.tension !== void 0)) {
      return "spring";
    }
    throw Error("Unrecognized animation configuration");
  },
  _onAnimationEnd: function(finished, onFinish, onEnd) {
    if (finished) {
      onFinish();
    }
    onEnd(finished);
    return this.didAnimationEnd.emit(finished);
  },
  _detachReaction: function() {
    if (!this.isReactive) {
      return;
    }
    this._reactionListener.stop();
    this._reactionListener = null;
    this._reaction = null;
  },
  _detachAnimated: function() {
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
