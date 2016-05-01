var AnimatedValue, Animation, Event, Factory, Maybe, NativeValue, Null, Progress, Reaction, Tracer, assert, assertType, clampValue, combine, configTypes, emptyFunction, isType, ref, roundValue, steal, sync, validateTypes;

require("isDev");

ref = require("type-utils"), isType = ref.isType, validateTypes = ref.validateTypes, assertType = ref.assertType, assert = ref.assert, Maybe = ref.Maybe, Null = ref.Null;

AnimatedValue = require("Animated").AnimatedValue;

emptyFunction = require("emptyFunction");

roundValue = require("roundValue");

clampValue = require("clampValue");

Progress = require("progress");

Reaction = require("reaction");

Factory = require("factory");

combine = require("combine");

Tracer = require("tracer");

Event = require("event");

steal = require("steal");

sync = require("sync");

Animation = require("./Animation");

if (isDev) {
  configTypes = {};
  configTypes.animate = {
    type: Function.Kind,
    onUpdate: Maybe(Function.Kind),
    onEnd: Maybe(Function.Kind),
    onFinish: Maybe(Function.Kind)
  };
  configTypes.track = {
    fromRange: Progress.Range,
    toRange: Progress.Range
  };
  configTypes.setValue = {
    clamp: Boolean.Maybe,
    round: [Null, Number.Maybe]
  };
  configTypes.setProgress = {
    fromValue: Number,
    toValue: Number,
    clamp: Boolean.Maybe,
    round: [Null, Number.Maybe]
  };
}

module.exports = NativeValue = Factory("NativeValue", {
  initArguments: function(value, keyPath) {
    assertType(keyPath, String.Maybe, "keyPath");
    return arguments;
  },
  getFromCache: function(value) {
    if (isType(value, NativeValue.Kind)) {
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
        this._assertNonReactive();
        if (this.isAnimated) {
          this._animated.setValue(newValue);
          return;
        }
        return this._setValue(newValue);
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
    distance: {
      get: function() {
        return this._toValue - this._fromValue;
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
    animation: {
      get: function() {
        return this._animation;
      }
    },
    isAnimated: {
      get: function() {
        return this._animated !== null;
      }
    },
    isAnimating: {
      get: function() {
        return this._animation !== null;
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
        if (newValue === null) {
          return this._detachReaction();
        } else {
          return this._attachReaction(newValue);
        }
      }
    }
  },
  initFrozenValues: function() {
    return {
      didSet: Event(),
      didAnimationEnd: Event({
        maxRecursion: 10
      })
    };
  },
  initValues: function() {
    return {
      clamp: false,
      round: null,
      _keyPath: null,
      _reaction: null,
      _reactionListener: null,
      _animated: null,
      _animation: null,
      _animatedListener: null,
      _tracer: emptyFunction,
      _retainCount: 1
    };
  },
  initReactiveValues: function() {
    return {
      _value: null,
      _fromValue: null,
      _toValue: null
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
      this._keyPath = keyPath;
      return this.value = value;
    }
  },
  setValue: function(newValue, config) {
    assertType(newValue, Number);
    if (config == null) {
      config = {};
    }
    if (config.clamp == null) {
      config.clamp = this.clamp;
    }
    if (config.round == null) {
      config.round = this.round;
    }
    if (isDev) {
      validateTypes(config, configTypes.setValue);
    }
    if (config.clamp === true) {
      assert(this._fromValue != null, "Must have a 'fromValue' defined!");
      assert(this._toValue != null, "Must have a 'toValue' defined!");
      newValue = clampValue(newValue, this._fromValue, this._toValue);
    }
    if (config.round != null) {
      newValue = roundValue(newValue, config.round);
    }
    return this.value = newValue;
  },
  animate: function(config) {
    var callbacks, onEnd;
    this._assertNonReactive();
    if (isDev) {
      this._tracer = Tracer("When the Animation was created");
    }
    if (this._animation) {
      this._animation.stop();
    }
    this._attachAnimated();
    if (isDev) {
      validateTypes(config, configTypes.animate);
    }
    callbacks = {
      onUpdate: steal(config, "onUpdate"),
      onFinish: steal(config, "onFinish", emptyFunction),
      onEnd: steal(config, "onEnd", emptyFunction)
    };
    onEnd = (function(_this) {
      return function(finished) {
        _this._animation = null;
        if (finished) {
          callbacks.onFinish();
        }
        callbacks.onEnd(finished);
        return _this.didAnimationEnd.emit(finished);
      };
    })(this);
    return this._animation = Animation({
      animated: this._animated,
      type: steal(config, "type"),
      config: config,
      onUpdate: callbacks.onUpdate,
      onEnd: onEnd
    });
  },
  track: function(nativeValue, config) {
    var fromRange, toRange;
    assert(!this._tracking, "Already tracking another value!");
    assertType(nativeValue, NativeValue.Kind);
    fromRange = config.fromRange != null ? config.fromRange : config.fromRange = {};
    if (fromRange.fromValue == null) {
      fromRange.fromValue = nativeValue._fromValue;
    }
    if (fromRange.toValue == null) {
      fromRange.toValue = nativeValue._toValue;
    }
    toRange = config.toRange != null ? config.toRange : config.toRange = {};
    if (toRange.fromValue == null) {
      toRange.fromValue = this._fromValue;
    }
    if (toRange.toValue == null) {
      toRange.toValue = this._toValue;
    }
    if (isDev) {
      validateTypes(config, configTypes.track);
    }
    this._tracking = nativeValue.didSet((function(_this) {
      return function(value) {
        var progress;
        progress = Progress.fromValue(value, fromRange);
        return _this.value = Progress.toValue(progress, toRange);
      };
    })(this));
    this._tracking._onEvent(nativeValue.value);
    this._tracking._onDefuse = (function(_this) {
      return function() {
        return _this._tracking = null;
      };
    })(this);
    return this._tracking;
  },
  stopTracking: function() {
    if (this._tracking) {
      this._tracking.stop();
    }
  },
  getProgress: function(value, config) {
    this._assertNonReactive();
    if (isType(value, Object)) {
      config = value;
      value = this._value;
    } else {
      if (config == null) {
        config = {};
      }
      if (value == null) {
        value = this._value;
      }
    }
    if (config.fromValue == null) {
      config.fromValue = this._fromValue != null ? this._fromValue : this._value;
    }
    if (config.toValue == null) {
      config.toValue = this._toValue;
    }
    assertType(value, Number);
    if (isDev) {
      validateTypes(config, configTypes.setProgress);
    }
    return Progress.fromValue(value, config);
  },
  setProgress: function(progress, config) {
    var value;
    this._assertNonReactive();
    if (config == null) {
      config = {};
    }
    if (config.fromValue == null) {
      config.fromValue = this._fromValue;
    }
    if (config.toValue == null) {
      config.toValue = this._toValue;
    }
    if (config.clamp == null) {
      config.clamp = this.clamp;
    }
    if (config.round == null) {
      config.round = this.round;
    }
    assertType(progress, Number);
    if (isDev) {
      validateTypes(config, configTypes.setProgress);
    }
    value = Progress.toValue(progress, config);
    if (config.round != null) {
      value = roundValue(value, config.round);
    }
    this.value = value;
  },
  willProgress: function(config) {
    this._assertNonReactive();
    if (isDev) {
      validateTypes(config, configTypes.setProgress);
    }
    if (config.clamp !== void 0) {
      this.clamp = config.clamp;
    }
    if (config.round !== void 0) {
      this.round = config.round;
    }
    this._fromValue = config.fromValue != null ? config.fromValue : config.fromValue = this._value;
    this._toValue = config.toValue;
  },
  __attach: function() {
    this._retainCount += 1;
  },
  __detach: function() {
    this._retainCount -= 1;
    if (this._retainCount > 0) {
      return;
    }
    this._detachReaction();
    this._detachAnimated();
  },
  _assertNonReactive: function(reason) {
    return assert(!this.isReactive, reason);
  },
  _setValue: function(newValue) {
    if (this._value === newValue) {
      return;
    }
    this._value = newValue;
    return this.didSet.emit(newValue);
  },
  _attachReaction: function(reaction) {
    var base;
    if (!isType(reaction, Reaction)) {
      reaction = Reaction.sync(reaction);
    }
    assertType(reaction, Reaction);
    if (this.isReactive) {
      this._detachReaction();
    } else {
      this._detachAnimated();
    }
    this._tracer = reaction._traceInit;
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
    if (this._animated) {
      return;
    }
    this._animated = new AnimatedValue(this._value);
    return this._animatedListener = this._animated.didSet((function(_this) {
      return function(value) {
        return _this._setValue(value);
      };
    })(this));
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
    this._animatedListener.stop();
    this._animatedListener = null;
    this._animated = null;
  }
});

//# sourceMappingURL=../../map/src/NativeValue.map
