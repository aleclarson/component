var AnimatedValue, Any, Event, Nan, NativeAnimation, NativeValue, Null, Progress, Reaction, Tracer, Type, Void, assert, assertType, assertTypes, clampValue, combine, configTypes, emptyFunction, hook, isConstructor, isType, mutable, roundValue, steal, type;

require("isDev");

AnimatedValue = require("Animated").AnimatedValue;

mutable = require("Property").mutable;

emptyFunction = require("emptyFunction");

isConstructor = require("isConstructor");

assertTypes = require("assertTypes");

assertType = require("assertType");

roundValue = require("roundValue");

clampValue = require("clampValue");

Progress = require("progress");

Reaction = require("reaction");

combine = require("combine");

assert = require("assert");

Tracer = require("tracer");

isType = require("isType");

Event = require("Event");

steal = require("steal");

Void = require("Void");

Null = require("Null");

Type = require("Type");

hook = require("hook");

Any = require("Any");

Nan = require("Nan");

NativeAnimation = require("./NativeAnimation");

type = Type("NativeValue");

type.argumentTypes = {
  value: Any,
  keyPath: String.Maybe
};

type.returnExisting(function(value) {
  if (value instanceof NativeValue) {
    return value;
  }
});

type.trace();

type.defineFrozenValues({
  didSet: function() {
    return Event();
  },
  didAnimationEnd: function() {
    return Event();
  }
});

type.defineValues({
  _clamp: false,
  _round: null,
  _keyPath: null,
  _reaction: null,
  _reactionListener: null,
  _animated: null,
  _animatedListener: null,
  _retainCount: 1
});

type.defineReactiveValues({
  _value: null,
  _fromValue: null,
  _toValue: null,
  _animation: null
});

type.initInstance(function(value, keyPath) {
  if (isConstructor(value, Reaction)) {
    throw Error("NativeValue must create its own Reaction!");
  }
  this._keyPath = keyPath;
  if (isType(value, [Object, Function.Kind])) {
    return this._attachReaction(value);
  } else {
    return this.value = value;
  }
});

type.defineGetters({
  fromValue: function() {
    return this._fromValue;
  },
  toValue: function() {
    return this._toValue;
  },
  distance: function() {
    return this._toValue - this._fromValue;
  },
  isReactive: function() {
    return this._reaction !== null;
  },
  isAnimated: function() {
    return this._animated !== null;
  },
  isAnimating: function() {
    return this._animation !== null;
  }
});

type.definePrototype({
  keyPath: {
    get: function() {
      return this._keyPath;
    },
    set: function(keyPath) {
      this._keyPath = keyPath;
      return this._reaction && (this._reaction.keyPath = keyPath);
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
        this._animated.setValue(newValue);
        return;
      }
      return this._setValue(newValue);
    }
  },
  getValue: {
    get: function() {
      return mutable.define(this, "getValue", {
        value: (function(_this) {
          return function() {
            return _this._value;
          };
        })(this)
      });
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
  },
  progress: {
    get: function() {
      return this.getProgress();
    },
    set: function(progress) {
      return this.setProgress(progress);
    }
  }
});

type.defineMethods({
  setValue: function(newValue, config) {
    assertType(newValue, Number);
    if (config == null) {
      config = {};
    }
    if (config.clamp == null) {
      config.clamp = this._clamp;
    }
    if (config.round == null) {
      config.round = this._round;
    }
    if (isDev) {
      assertTypes(config, configTypes.setValue);
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
    var onEnd, onFinish;
    this._assertNonReactive();
    isDev && (this._tracers.animate = Tracer("NativeValue::animate()"));
    this.stopAnimation();
    this._attachAnimated();
    isDev && assertTypes(config, configTypes.animate);
    onFinish = steal(config, "onFinish", emptyFunction);
    onEnd = steal(config, "onEnd", emptyFunction);
    this._animation = NativeAnimation({
      animated: this._animated,
      onUpdate: steal(config, "onUpdate"),
      onEnd: (function(_this) {
        return function(finished) {
          _this._animation = null;
          finished && onFinish();
          onEnd(finished);
          return _this.didAnimationEnd.emit(finished);
        };
      })(this)
    });
    this._animation.start(config);
    return this._animation;
  },
  stopAnimation: function() {
    var animation;
    animation = this._animation;
    animation && animation.stop();
  },
  track: function(nativeValue, config) {
    var fromRange, listener, onChange, toRange;
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
      assertTypes(config, configTypes.track);
    }
    onChange = (function(_this) {
      return function(value) {
        var progress;
        progress = Progress.fromValue(value, fromRange);
        return _this.value = Progress.toValue(progress, toRange);
      };
    })(this);
    onChange(nativeValue.value);
    listener = nativeValue.didSet(onChange);
    return this._tracking = listener.start();
  },
  stopTracking: function() {
    var tracking;
    tracking = this._tracking;
    if (tracking) {
      tracking.stop();
    }
  },
  getProgress: function(value, config) {
    this._assertNonReactive();
    if (isConstructor(value, Object)) {
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
      assertTypes(config, configTypes.setProgress);
    }
    return Progress.fromValue(value, config);
  },
  setProgress: function(progress, config) {
    var value;
    this._assertNonReactive();
    if (config.fromValue == null) {
      config.fromValue = this._fromValue;
    }
    if (config.toValue == null) {
      config.toValue = this._toValue;
    }
    assertType(progress, Number);
    if (isDev) {
      assertTypes(config, configTypes.setProgress);
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
      assertTypes(config, configTypes.setProgress);
    }
    this._fromValue = config.fromValue != null ? config.fromValue : config.fromValue = this._value;
    this._toValue = config.toValue;
  },
  __attach: function() {
    return this._retainCount += 1;
  },
  __detach: function() {
    this._retainCount -= 1;
    if (this._retainCount > 0) {
      return;
    }
    this._detachReaction();
    return this._detachAnimated();
  },
  _assertNonReactive: function(reason) {
    return assert(!this.isReactive, reason);
  },
  _setValue: function(newValue) {
    if (this._value === newValue) {
      return;
    }
    if (isType(newValue, Number)) {
      assert(!Nan.test(newValue), "Unexpected NaN value!");
    }
    this._value = newValue;
    return this.didSet.emit(newValue);
  },
  _attachReaction: function(options) {
    var listener, reaction;
    if (isConstructor(options, Object)) {
      if (options.keyPath == null) {
        options.keyPath = this.keyPath;
      }
      reaction = Reaction.sync(options);
    } else if (options instanceof Function) {
      reaction = Reaction.sync({
        keyPath: this.keyPath,
        get: options
      });
    } else {
      return;
    }
    if (this.isReactive) {
      this._detachReaction();
    } else {
      this._detachAnimated();
    }
    isDev && (this._tracers.reaction = reaction._traceInit);
    this._reaction = reaction;
    listener = reaction.didSet((function(_this) {
      return function(value) {
        return _this._setValue(value);
      };
    })(this));
    this._reactionListener = listener.start();
    return this._setValue(reaction.value);
  },
  _attachAnimated: function() {
    var listener;
    if (this._animated) {
      return;
    }
    this._animated = new AnimatedValue(this._value);
    listener = this._animated.didSet((function(_this) {
      return function(value) {
        return _this._setValue(value);
      };
    })(this));
    return this._animatedListener = listener.start();
  },
  _detachReaction: function() {
    if (!this.isReactive) {
      return;
    }
    this._reactionListener.stop();
    this._reactionListener = null;
    this._reaction.stop();
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

module.exports = NativeValue = type.build();

if (isDev) {
  configTypes = {};
  configTypes.animate = {
    type: Function.Kind,
    onUpdate: [Function.Kind, Void],
    onEnd: [Function.Kind, Void],
    onFinish: [Function.Kind, Void]
  };
  configTypes.track = {
    fromRange: Progress.Range,
    toRange: Progress.Range
  };
  configTypes.setValue = {
    clamp: Boolean.Maybe,
    round: [Number, Null, Void]
  };
  configTypes.setProgress = {
    fromValue: Number,
    toValue: Number,
    clamp: Boolean.Maybe,
    round: Boolean.Maybe
  };
}

//# sourceMappingURL=map/NativeValue.map
