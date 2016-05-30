var AnimatedValue, Animation, Any, Event, NativeValue, Null, Progress, Reaction, Tracer, Type, Void, assert, assertType, assertTypes, clampValue, combine, configTypes, emptyFunction, isConstructor, isType, roundValue, steal, type;

require("isDev");

AnimatedValue = require("Animated").AnimatedValue;

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

Event = require("event");

steal = require("steal");

Void = require("Void");

Null = require("Null");

Type = require("Type");

Any = require("Any");

Animation = require("./Animation");

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

type.defineProperties({
  keyPath: {
    get: function() {
      return this._keyPath;
    },
    set: function(keyPath) {
      var ref;
      this._keyPath = keyPath;
      return (ref = this._reaction) != null ? ref.keyPath = keyPath : void 0;
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
  isAnimated: {
    get: function() {
      return this._animated !== null;
    }
  },
  isAnimating: {
    get: function() {
      return this._animation !== null;
    }
  }
});

type.exposeGetters(["animation"]);

type.defineFrozenValues({
  didSet: function() {
    return Event();
  },
  didAnimationEnd: function() {
    return Event({
      maxRecursion: 10
    });
  }
});

type.defineValues({
  clamp: false,
  round: null,
  _keyPath: null,
  _reaction: null,
  _reactionListener: null,
  _animated: null,
  _animation: null,
  _animatedListener: null,
  _retainCount: 1
});

if (isDev) {
  type.defineValues({
    _traceInit: function() {
      return Tracer("NativeValue()");
    },
    _traceAnimate: null,
    _traceReaction: null
  });
}

type.defineReactiveValues({
  _value: null,
  _fromValue: null,
  _toValue: null
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

type.defineMethods({
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
    var callbacks, onEnd;
    this._assertNonReactive();
    if (isDev) {
      this._traceAnimate = Tracer("When the Animation was created");
    }
    if (this._animation) {
      this._animation.stop();
    }
    this._attachAnimated();
    if (isDev) {
      assertTypes(config, configTypes.animate);
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
  stopAnimation: function() {
    var animation;
    animation = this._animation;
    if (animation) {
      animation.stop();
    }
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
      assertTypes(config, configTypes.track);
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
    this._value = newValue;
    return this.didSet.emit(newValue);
  },
  _attachReaction: function(reaction) {
    var base;
    if (isConstructor(reaction, Object)) {
      reaction = Reaction.sync(reaction);
    } else if (reaction instanceof Function) {
      reaction = Reaction.sync({
        get: reaction
      });
    }
    assertType(reaction, Reaction);
    if (this.isReactive) {
      this._detachReaction();
    } else {
      this._detachAnimated();
    }
    if (isDev) {
      this._traceReaction = reaction._traceInit;
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
