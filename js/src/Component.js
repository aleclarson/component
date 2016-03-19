var Component, Event, ExceptionsManager, NamedFunction, NativeValue, Random, ReactComponent, ReactCurrentOwner, ReactElement, Reaction, ReactiveGetter, StyleSheet, Void, assertType, combine, define, emptyFunction, flattenStyle, hook, isKind, isType, log, ref1, setKind, setType, steal, sync, throwFailure, validateTypes;

ref1 = require("type-utils"), setKind = ref1.setKind, setType = ref1.setType, isType = ref1.isType, isKind = ref1.isKind, assertType = ref1.assertType, validateTypes = ref1.validateTypes, Void = ref1.Void;

throwFailure = require("failure").throwFailure;

sync = require("io").sync;

ReactCurrentOwner = require("ReactCurrentOwner");

ExceptionsManager = require("ExceptionsManager");

ReactiveGetter = require("ReactiveGetter");

ReactComponent = require("ReactComponent");

NamedFunction = require("named-function");

emptyFunction = require("emptyFunction");

ReactElement = require("ReactElement");

flattenStyle = require("flattenStyle");

StyleSheet = require("StyleSheet");

Reaction = require("reaction");

combine = require("combine");

define = require("define");

Random = require("random");

Event = require("event");

steal = require("steal");

hook = require("hook");

log = require("lotus-log");

NativeValue = require("./NativeValue");

Component = NamedFunction("Component", function(name, config) {
  var factory, mixins, prototype, statics, styles, type;
  assertType(name, String, "name");
  assertType(config, Object, "config");
  mixins = steal(config, "mixins", []);
  sync.each(mixins, function(mixin) {
    assertType(mixin, Function, {
      name: name,
      mixin: mixin,
      mixins: mixins
    });
    return mixin(config);
  });
  validateTypes(config, Component.configTypes);
  statics = steal(config, "statics", {});
  styles = steal(config, "styles");
  if (styles != null) {
    statics.styles = {
      value: StyleSheet.create(styles)
    };
  }
  Component.enforcePropValidation(name, config, statics);
  Component.addPreventableRendering(name, config);
  Component.catchErrorsWhenRendering(config);
  Component.startReactionsWhenMounting(config);
  Component.stopReactionsWhenUnmounting(config);
  Component.stopListenersWhenUnmounting(config);
  Component.detachNativeValuesWhenUnmounting(config);
  type = Component.createType(name, {
    boundMethods: steal(config, "boundMethods", []),
    customValues: steal(config, "customValues"),
    init: steal(config, "init", emptyFunction),
    initState: steal(config, "initState", emptyFunction),
    initValues: steal(config, "initValues", emptyFunction),
    initReactiveValues: steal(config, "initReactiveValues", emptyFunction),
    initNativeValues: steal(config, "initNativeValues", emptyFunction),
    initListeners: steal(config, "initListeners")
  });
  statics = sync.map(statics, function(value, key) {
    var enumerable;
    enumerable = key[0] !== "_";
    if (isType(value, Object)) {
      if (value.frozen == null) {
        value.frozen = true;
      }
      if (value.enumerable == null) {
        value.enumerable = enumerable;
      }
      return value;
    }
    return {
      value: value,
      frozen: true,
      enumerable: enumerable
    };
  });
  prototype = sync.map(config, function(value, key) {
    return {
      value: value,
      enumerable: key[0] !== "_",
      configurable: false
    };
  });
  define(type, statics);
  define(type.prototype, "styles", statics.styles);
  define(type.prototype, prototype);
  statics.type = type;
  factory = Component.createFactory(type);
  return define(factory, statics);
});

module.exports = setKind(Component, ReactComponent);

define(Component.prototype, function() {
  this.options = {
    enumerable: false
  };
  return this({
    __owners: {
      get: function() {
        var instance, owners, ref2;
        owners = [];
        instance = this;
        while (instance != null) {
          owners.push(instance);
          instance = (ref2 = instance._reactInternalInstance._currentElement._owner) != null ? ref2._instance : void 0;
        }
        return owners;
      }
    },
    __addReaction: function(key, reaction, listener) {
      if (this.__reactions == null) {
        define(this, {
          __reactions: {
            value: {},
            enumerable: false
          }
        });
      }
      if (this.__reactions[key] != null) {
        throw Error("Conflicting reactions are both named '" + key + "'.");
      }
      this.__reactions[key] = {
        reaction: reaction,
        listener: listener
      };
      return reaction;
    },
    __attachNativeValue: function(key, nativeValue) {
      assertType(nativeValue, NativeValue.Kind);
      this.__nativeValues[key] = nativeValue;
      return define(this, key, {
        value: nativeValue,
        enumerable: key[0] !== "_",
        frozen: true
      });
    },
    __createNativeValue: function(key, value) {
      var nativeValue;
      if (value === void 0) {
        return;
      }
      nativeValue = NativeValue(value, this.constructor.name + "." + key);
      this.__attachNativeValue(key, nativeValue);
      if (nativeValue.isReactive) {
        return this.__addReaction(key, nativeValue._reaction);
      }
    }
  });
});

define(Component, {
  configTypes: {
    value: {
      propTypes: [Object, Void],
      propDefaults: [Object, Void],
      events: [Array, Void],
      boundMethods: [Array, Void],
      customValues: [Object, Void],
      init: [Function, Void],
      initProps: [Function, Void],
      initState: [Function, Void],
      initValues: [Function, Void],
      initReactiveValues: [Function, Void],
      initNativeValues: [Function, Void],
      initListeners: [Function, Void],
      isRenderPrevented: [Function.Kind, Void],
      render: Function.Kind,
      styles: [Object, Void],
      statics: [Object, Void],
      mixins: [Array, Void]
    }
  },
  createType: function(name, config) {
    var constructor, type;
    constructor = function(props) {
      var error, inst;
      inst = setType({
        props: props
      }, type);
      try {
        Component.initComponent.call(inst, config, props);
      } catch (_error) {
        error = _error;
        throwFailure(error, {
          method: "initComponent",
          componentName: name,
          component: inst,
          props: props
        });
      }
      return inst;
    };
    type = NamedFunction(name, constructor);
    return setKind(type, Component);
  },
  createFactory: function(type) {
    return function(props) {
      var key, mixins, ref;
      if (props == null) {
        props = {};
      }
      if (isType(props, Array)) {
        props = combine.apply(null, props);
      }
      if (props.mixins != null) {
        mixins = steal(props, "mixins");
        assertType(mixins, Array, "props.mixins");
        props = combine.apply(null, [{}].concat(mixins.concat(props)));
      }
      key = props.key != null ? "" + props.key : null;
      delete props.key;
      ref = props.ref != null ? props.ref : null;
      delete props.ref;
      return define({}, function() {
        this.options = {
          configurable: false
        };
        return this({
          $$typeof: ReactElement.type,
          type: type,
          key: key,
          ref: ref,
          props: {
            value: props
          },
          _owner: {
            value: ReactCurrentOwner.current
          },
          _store: {
            value: {
              validated: false
            }
          },
          _initError: Error()
        });
      });
    };
  },
  initComponent: function(config, props) {
    var prevAutoStart;
    prevAutoStart = Reaction.autoStart;
    Reaction.autoStart = false;
    Component.initBoundMethods.call(this, config);
    Component.initCustomValues.call(this, config);
    Component.initValues.call(this, config);
    Component.initReactiveValues.call(this, config);
    Component.initNativeValues.call(this, config);
    Component.initState.call(this, config);
    Component.initListeners.call(this, config);
    Reaction.autoStart = prevAutoStart;
    return config.init.call(this);
  },
  initCustomValues: function(arg) {
    var customValues;
    customValues = arg.customValues;
    if (!isType(customValues, Object)) {
      return;
    }
    return define(this, function() {
      this.options = {
        configurable: false
      };
      return this(customValues);
    });
  },
  initBoundMethods: function(config) {
    var boundMethods;
    boundMethods = {};
    sync.each(config.boundMethods, (function(_this) {
      return function(key) {
        var boundMethod, method;
        method = _this[key];
        if (!isKind(method, Function)) {
          throw Error(("'" + _this.constructor.name + "." + key + "' must be a Function") + ", because you included it in the 'boundMethods' array.");
        }
        boundMethod = method.bind(_this);
        boundMethod.toString = function() {
          return method.toString();
        };
        return boundMethods[key] = {
          enumerable: key[0] !== "_",
          value: boundMethod
        };
      };
    })(this));
    return define(this, function() {
      this.options = {
        frozen: true
      };
      return this(boundMethods);
    });
  },
  initValues: function(config) {
    var values;
    values = config.initValues.call(this);
    if (values == null) {
      return;
    }
    values = sync.map(values, function(value, key) {
      return {
        enumerable: key[0] !== "_",
        value: value
      };
    });
    return define(this, function() {
      this.options = {
        configurable: false
      };
      return this(values);
    });
  },
  initReactiveValues: function(config) {
    var error, reactions, values;
    values = config.initReactiveValues.call(this);
    if (values == null) {
      return;
    }
    if (isType(values, Array)) {
      values = combine.apply(null, values);
    }
    if (!isType(values, Object)) {
      error = TypeError("'initReactiveValues' must return an Object or Array!");
      throwFailure(error, {
        values: values,
        component: this
      });
    }
    reactions = {};
    values = sync.filter(values, (function(_this) {
      return function(reaction, key) {
        if (!isType(reaction, Reaction)) {
          return true;
        }
        reactions[key] = reaction;
        if (reaction.keyPath == null) {
          reaction.keyPath = _this.constructor.name + "." + key;
        }
        return false;
      };
    })(this));
    values = sync.map(values, function(value, key) {
      return {
        enumerable: key[0] !== "_",
        reactive: true,
        value: value
      };
    });
    reactions = sync.map(reactions, (function(_this) {
      return function(reaction, key) {
        _this.__addReaction(key, reaction);
        return {
          enumerable: key[0] !== "_",
          get: function() {
            return reaction.value;
          }
        };
      };
    })(this));
    return define(this, function() {
      this.options = {
        configurable: false
      };
      this(values);
      return this(reactions);
    });
  },
  initNativeValues: function(config) {
    var nativeValues;
    nativeValues = config.initNativeValues.call(this);
    if (nativeValues == null) {
      return;
    }
    assertType(nativeValues, Object, "nativeValues");
    define(this, {
      __nativeValues: {
        value: {},
        enumerable: false
      }
    });
    return sync.each(nativeValues, (function(_this) {
      return function(value, key) {
        if (isKind(value, NativeValue)) {
          return _this.__attachNativeValue(key, value);
        } else {
          return _this.__createNativeValue(key, value);
        }
      };
    })(this));
  },
  initState: function(config) {
    var state;
    state = config.initState.call(this);
    if (state == null) {
      return;
    }
    assertType(state, Object, "state");
    this.state = state;
    return sync.each(state, (function(_this) {
      return function(value, key) {
        if (!isType(value, Reaction)) {
          return;
        }
        if (value.keyPath == null) {
          value.keyPath = _this.constructor.name + ".state." + key;
        }
        _this.state[key] = value._value;
        return _this.__addReaction("state." + key, value, function(newValue) {
          var newProps;
          newProps = {};
          newProps[key] = newValue;
          return _this.setState(newProps);
        });
      };
    })(this));
  },
  initListeners: function(config) {
    var onListen;
    if (config.initListeners == null) {
      return;
    }
    define(this, {
      __listeners: {
        value: [],
        enumerable: false
      }
    });
    onListen = Event.didListen((function(_this) {
      return function(event, listener) {
        return _this.__listeners.push(listener);
      };
    })(this));
    config.initListeners.call(this);
    return onListen.stop();
  },
  startReactionsWhenMounting: function(config) {
    return hook.after(config, "componentWillMount", function() {
      if (this.__reactions == null) {
        return;
      }
      return sync.each(this.__reactions, (function(_this) {
        return function(arg, key) {
          var error, listener, reaction;
          reaction = arg.reaction, listener = arg.listener;
          if (listener != null) {
            reaction.addListener(listener);
          }
          try {
            return reaction.start();
          } catch (_error) {
            error = _error;
            return throwFailure(error, {
              key: key,
              reaction: reaction,
              component: _this
            });
          }
        };
      })(this));
    });
  },
  stopReactionsWhenUnmounting: function(config) {
    return hook.after(config, "componentWillUnmount", function() {
      if (this.__reactions == null) {
        return;
      }
      return sync.each(this.__reactions, function(arg) {
        var listener, reaction;
        reaction = arg.reaction, listener = arg.listener;
        reaction.stop();
        if (listener != null) {
          return reaction.removeListener(listener);
        }
      });
    });
  },
  stopListenersWhenUnmounting: function(config) {
    if (config.initListeners == null) {
      return;
    }
    return hook.after(config, "componentWillUnmount", function() {
      return sync.each(this.__listeners, function(listener) {
        return listener.stop();
      });
    });
  },
  detachNativeValuesWhenUnmounting: function(config) {
    return hook.after(config, "componentWillUnmount", function() {
      if (this.__nativeValues == null) {
        return;
      }
      return sync.each(this.__nativeValues, function(value) {
        return value.detach();
      });
    });
  },
  addPreventableRendering: function(name, config) {
    var isRenderPrevented, render, shouldUpdate;
    isRenderPrevented = steal(config, "isRenderPrevented");
    if (isRenderPrevented == null) {
      return;
    }
    hook.after(config, "init", function(args, values) {
      var shouldRender;
      shouldRender = Reaction.sync({
        get: (function(_this) {
          return function() {
            return !isRenderPrevented.call(_this);
          };
        })(this),
        didSet: (function(_this) {
          return function(shouldRender) {
            if (!(_this.__needsRender && shouldRender)) {
              return;
            }
            _this.__needsRender = false;
            try {
              return _this.forceUpdate();
            } catch (_error) {}
          };
        })(this)
      });
      return define(this, function() {
        this.options = {
          enumerable: false
        };
        this("__needsRender", {
          value: false
        });
        return this("__shouldRender", {
          get: function() {
            return shouldRender.value;
          }
        });
      });
    });
    shouldUpdate = steal(config, "shouldComponentUpdate", emptyFunction.thatReturnsTrue);
    config.shouldComponentUpdate = function() {
      if (this.__shouldRender) {
        return shouldUpdate.apply(this, arguments);
      }
      this.__needsRender = true;
      return false;
    };
    render = steal(config, "render");
    return config.render = function() {
      if (this.__shouldRender) {
        return render.call(this);
      }
      this.__needsRender = true;
      return false;
    };
  },
  catchErrorsWhenRendering: function(config) {
    var render, renderSafely;
    render = steal(config, "render");
    renderSafely = function() {
      var element, error;
      try {
        element = render.call(this);
      } catch (_error) {
        error = _error;
        element = this._reactInternalInstance._currentElement;
        throwFailure(error, {
          method: this.constructor.name + ".render",
          component: this,
          stack: ["::   When component was constructed  ::", element._initError]
        });
      }
      return element || false;
    };
    renderSafely.toString = function() {
      return render.toString();
    };
    return config.render = renderSafely;
  },
  enforcePropValidation: function(name, config, statics) {
    var events, initProps, propDefaults, propTypes;
    initProps = steal(config, "initProps", emptyFunction);
    propTypes = steal(config, "propTypes");
    propDefaults = steal(config, "propDefaults");
    events = steal(config, "events");
    if ((events != null ? events.length : void 0) > 0) {
      if (propTypes == null) {
        propTypes = {};
      }
      if (propDefaults == null) {
        propDefaults = {};
      }
      sync.each(events, function(event) {
        propTypes[event] = [Function, Void];
        return propDefaults[event] = emptyFunction;
      });
    }
    statics.propTypes = {
      value: propTypes,
      frozen: false
    };
    statics.propDefaults = {
      value: propDefaults
    };
    return statics._processProps = function(props) {
      var error;
      if (propDefaults != null) {
        if (isType(props, Object)) {
          Component.mergeDefaults(props, propDefaults);
        } else {
          props = combine({}, propDefaults);
        }
      }
      initProps.call(this, props);
      if ((propTypes != null) && isType(props, Object)) {
        try {
          validateTypes(props, propTypes);
        } catch (_error) {
          error = _error;
          throwFailure(error, {
            method: "_processProps",
            element: this,
            props: props,
            propTypes: propTypes
          });
        }
      }
      return props;
    };
  },
  mergeDefaults: function(values, defaultValues) {
    var defaultValue, key, value;
    for (key in defaultValues) {
      defaultValue = defaultValues[key];
      value = values[key];
      if (isType(defaultValue, Object)) {
        if (isType(value, Object)) {
          Component.mergeDefaults(value, defaultValue);
        } else if (value === void 0) {
          values[key] = combine({}, defaultValue);
        }
      } else if (value === void 0) {
        values[key] = defaultValue;
      }
    }
  }
});

//# sourceMappingURL=../../map/src/Component.map
