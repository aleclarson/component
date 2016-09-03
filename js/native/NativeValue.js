var AnimatedValue, Event, NativeAnimation, NativeValue, Number, Progress, Reaction, Tracer, Tracker, Type, assertType, assertTypes, clampValue, configTypes, emptyFunction, isType, mergeDefaults, roundValue, steal, type;

require("isDev");

AnimatedValue = require("Animated").AnimatedValue;

Number = require("Nan").Number;

emptyFunction = require("emptyFunction");

mergeDefaults = require("mergeDefaults");

assertTypes = require("assertTypes");

assertType = require("assertType");

roundValue = require("roundValue");

clampValue = require("clampValue");

Progress = require("progress");

Reaction = require("reaction");

Tracker = require("tracker");

Tracer = require("tracer");

isType = require("isType");

Event = require("Event");

steal = require("steal");

Type = require("Type");

NativeAnimation = require("./NativeAnimation");

type = Type("NativeValue");

type.trace();

type.defineArgs({
  value: null,
  keyPath: String
});

isDev && type.initArgs(function(value) {
  if (value instanceof NativeValue) {
    throw TypeError("'value' cannot inherit from NativeValue!");
  }
  if (value instanceof Reaction) {
    throw TypeError("'value' cannot inherit from Reaction!");
  }
});

type.defineFrozenValues({
  didSet: function() {
    return Event();
  },
  didAnimationEnd: function() {
    return Event();
  }
});

type.defineValues({
  _dep: function() {
    return Tracker.Dependency();
  },
  _value: null,
  _keyPath: null,
  _clamp: false,
  _round: null,
  _reaction: null,
  _reactionListener: null,
  _animated: null,
  _animatedListener: null,
  _retainCount: 0
});

type.defineReactiveValues({
  _fromValue: null,
  _toValue: null,
  _animation: null
});

type.initInstance(function(value, keyPath) {
  this._keyPath = keyPath;
  if (isType(value, Function) || isType(value, Object)) {
    this._createReaction(value);
  } else {
    this.value = value;
  }
});

type.defineGetters({
  isReactive: function() {
    return this._reaction !== null;
  },
  isAnimated: function() {
    return this._animated !== null;
  },
  isAnimating: function() {
    return this._animation !== null;
  },
  animation: function() {
    return this._animation;
  },
  velocity: function() {
    if (this._animation) {
      return this._animation.velocity;
    } else {
      return 0;
    }
  },
  fromValue: function() {
    return this._fromValue;
  },
  toValue: function() {
    return this._toValue;
  },
  distance: function() {
    return this._toValue - this._fromValue;
  }
});

type.definePrototype({
  value: {
    get: function() {
      if (Tracker.isActive) {
        this._dep.depend();
      }
      return this._value;
    },
    set: function(newValue) {
      if (isDev && this.isReactive) {
        throw Error("Reaction-backed values cannot be mutated!");
      }
      if (this.isAnimated) {
        this._animated.setValue(newValue);
      } else {
        this._setValue(newValue);
      }
    }
  },
  keyPath: {
    get: function() {
      return this._keyPath;
    },
    set: function(keyPath) {
      this._keyPath = keyPath;
      this._reaction && (this._reaction.keyPath = keyPath);
    }
  },
  reaction: {
    get: function() {
      return this._reaction;
    },
    set: function(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.isReactive && this._deleteReaction();
        if (newValue !== null) {
          this._createReaction(newValue);
        }
      }
    }
  },
  progress: {
    get: function() {
      return this.getProgress();
    },
    set: function(progress) {
      this.setProgress(progress);
    }
  }
});

type.defineMethods({
  setValue: function(newValue, config) {
    if (config == null) {
      config = {};
    }
    if (config.clamp == null) {
      config.clamp = this._clamp;
    }
    if (config.round == null) {
      config.round = this._round;
    }
    isDev && assertTypes(config, configTypes.setValue);
    if (config.clamp === true) {
      if (isDev && (this._fromValue == null)) {
        throw Error("Must define 'config.fromValue' or 'this.fromValue'!");
      }
      if (isDev && (this._toValue == null)) {
        throw Error("Must define 'config.toValue' or 'this.toValue'!");
      }
      newValue = clampValue(newValue, this._fromValue, this._toValue);
    }
    if (config.round != null) {
      newValue = roundValue(newValue, config.round);
    }
    return this.value = newValue;
  },
  _setValue: function(newValue) {
    if (newValue !== this._value) {
      this._value = newValue;
      this._dep.changed();
      this.didSet.emit(newValue);
    }
  },
  getProgress: function(value, config) {
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
    if (isDev) {
      assertType(value, Number);
      assertTypes(config, configTypes.setProgress);
    }
    return Progress.fromValue(value, config);
  },
  setProgress: function(progress, config) {
    var value;
    if (isDev && this.isReactive) {
      throw Error("Reaction-backed values cannot be mutated!");
    }
    if (config) {
      mergeDefaults(config, this._getRange());
    } else {
      config = this._getRange();
    }
    if (isDev) {
      assertType(progress, Number);
      assertTypes(config, configTypes.setProgress);
    }
    value = Progress.toValue(progress, config);
    if (config.round != null) {
      value = roundValue(value, config.round);
    }
    this.value = value;
  },
  willProgress: function(config) {
    isDev && assertTypes(config, configTypes.setProgress);
    this._fromValue = config.fromValue != null ? config.fromValue : config.fromValue = this._value;
    this._toValue = config.toValue;
  },
  _getRange: function() {
    return {
      fromValue: this._fromValue,
      toValue: this._toValue
    };
  },
  __attach: function() {
    if (this._retainCount === 0) {
      this.isReactive && this._startReaction();
    }
    this._retainCount += 1;
    return this;
  },
  __detach: function() {
    if (isDev && this._retainCount === 0) {
      throw Error("Must call '__attach' for every call to '__detach'!");
    }
    if (this._retainCount > 1) {
      this._retainCount -= 1;
      return;
    }
    if (this._retainCount > 0) {
      this._retainCount -= 1;
    }
    this._detachReaction();
    this._detachAnimated();
  },
  _createReaction: function(options) {
    assertType(options, Object.or(Function));
    if (isType(options, Function)) {
      this._reaction = Reaction({
        keyPath: this.keyPath,
        get: options
      });
    } else {
      if (options.keyPath == null) {
        options.keyPath = this.keyPath;
      }
      this._reaction = Reaction(options);
    }
  },
  _startReaction: function() {
    if (isDev && !this.isReactive) {
      throw Error("Must call '_createReaction' before '_startReaction'!");
    }
    this._reactionListener = this._reaction.didSet((function(_this) {
      return function(value) {
        return _this._setValue(value);
      };
    })(this)).start();
    this._reaction.start();
  },
  _deleteReaction: function() {
    if (isDev && !this.isReactive) {
      throw Error("Must call '_createReaction' before '_deleteReaction'!");
    }
    this._reactionListener.stop();
    this._reactionListener = null;
    this._reaction.stop();
    this._reaction = null;
  },
  animate: function(config) {
    var onEnd, onFinish;
    if (isDev && this.isReactive) {
      throw Error("Reaction-backed values cannot be mutated!");
    }
    this.stopAnimation();
    this._createAnimated();
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
    if (this._animation) {
      this._animation.stop();
    }
  },
  _createAnimated: function() {
    if (this.isAnimated) {
      return;
    }
    this._animated = new AnimatedValue(this._value);
    return this._animatedListener = this._animated.didSet((function(_this) {
      return function(value) {
        return _this._setValue(value);
      };
    })(this)).start();
  },
  _deleteAnimated: function() {
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

isDev && (configTypes = (function() {
  var Null;
  Null = require("Null");
  return {
    animate: {
      type: Type,
      onUpdate: Function.Maybe,
      onFinish: Function.Maybe,
      onEnd: Function.Maybe
    },
    track: {
      fromRange: Progress.Range,
      toRange: Progress.Range
    },
    setValue: {
      clamp: Boolean.Maybe,
      round: Number.or(Null).Maybe
    },
    setProgress: {
      fromValue: Number,
      toValue: Number,
      clamp: Boolean.Maybe,
      round: Boolean.Maybe
    }
  };
})());

//# sourceMappingURL=map/NativeValue.map
