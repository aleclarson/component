var Component, Config, ExceptionsManager, NamedFunction, NativeValue, Random, ReactComponent, ReactCurrentOwner, ReactElement, Reaction, ReactiveGetter, StyleSheet, Void, _addPreventableRendering, _catchErrorsWhenRendering, _createFactory, _createType, _detachNativeValuesWhenUnmounting, _enforcePropValidation, _initBoundMethods, _initComponent, _initCustomValues, _initNativeValues, _initReactiveValues, _initState, _initValues, _mergeDefaults, _startReactionsWhenMounting, _stopReactionsWhenUnmounting, assertType, combine, define, emptyFunction, flattenStyle, isKind, isType, log, ref1, setKind, setType, steal, sync, throwFailure, validateTypes;

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

steal = require("steal");

log = require("lotus-log");

NativeValue = require("./NativeValue");

Config = {
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
  isRenderPrevented: [Function.Kind, Void],
  render: Function.Kind,
  styles: [Object, Void],
  statics: [Object, Void],
  mixins: [Array, Void]
};

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
  validateTypes(config, Config);
  statics = steal(config, "statics", {});
  styles = steal(config, "styles");
  if (styles != null) {
    statics.styles = {
      value: StyleSheet.create(styles)
    };
  }
  _enforcePropValidation(name, config, statics);
  _addPreventableRendering(name, config);
  _catchErrorsWhenRendering(config);
  _startReactionsWhenMounting(config);
  _stopReactionsWhenUnmounting(config);
  type = _createType(name, {
    boundMethods: steal(config, "boundMethods", []),
    customValues: steal(config, "customValues"),
    init: steal(config, "init", emptyFunction),
    initState: steal(config, "initState", emptyFunction),
    initValues: steal(config, "initValues", emptyFunction),
    initReactiveValues: steal(config, "initReactiveValues", emptyFunction),
    initNativeValues: steal(config, "initNativeValues", emptyFunction)
  });
  statics = sync.map(statics, function(value, key) {
    var enumerable;
    enumerable = key[0] !== "_";
    if (isType(value, Object)) {
      value.enumerable = enumerable;
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
      frozen: true,
      enumerable: key[0] !== "_"
    };
  });
  define(type, statics);
  define(type.prototype, "styles", statics.styles);
  define(type.prototype, prototype);
  statics.type = type;
  factory = _createFactory(type);
  return define(factory, statics);
});

module.exports = setKind(Component, ReactComponent);

define(Component.prototype, function() {
  this.options = {
    frozen: true
  };
  this({
    react: function(options) {
      var key, reaction;
      if (options.sync == null) {
        options.sync = true;
      }
      key = Random.id();
      reaction = Reaction(options);
      return this.__addReaction(key, reaction);
    }
  });
  this.enumerable = false;
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
      if (this._reactions == null) {
        this._reactions = {};
      }
      if (this._reactions[key]) {
        throw Error("Conflicting reactions are both named '" + key + "'.");
      }
      this._reactions[key] = {
        reaction: reaction,
        listener: listener
      };
      return reaction;
    },
    __attachNativeValue: function(key, nativeValue) {
      assertType(nativeValue, NativeValue.Kind);
      this._nativeValues[key] = nativeValue;
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

_createType = function(name, config) {
  var _construct, type;
  type = NamedFunction(name, _construct = function(props) {
    var error, inst;
    inst = setType({
      props: props
    }, type);
    try {
      _initComponent.call(inst, config, props);
    } catch (_error) {
      error = _error;
      throwFailure(error, {
        method: name + "._initComponent",
        component: inst,
        props: props
      });
    }
    return inst;
  });
  return setKind(type, Component);
};

_createFactory = function(type) {
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
};

_initComponent = function(config, props) {
  var prevAutoStart;
  define(this, function() {
    this.options = {
      enumerable: false,
      configurable: false
    };
    return this({
      _reactions: null,
      _nativeValues: null
    });
  });
  prevAutoStart = Reaction.autoStart;
  Reaction.autoStart = false;
  _initBoundMethods.call(this, config);
  _initCustomValues.call(this, config);
  _initValues.call(this, config);
  _initReactiveValues.call(this, config);
  _initNativeValues.call(this, config);
  _initState.call(this, config);
  config.init.call(this);
  return Reaction.autoStart = prevAutoStart;
};

_initCustomValues = function(arg) {
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
};

_initBoundMethods = function(config) {
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
};

_initValues = function(config) {
  var values;
  values = config.initValues.call(this);
  if (values == null) {
    return;
  }
  values = sync.filter(values, (function(_this) {
    return function(reaction, key) {
      var error;
      if (!isType(reaction, Reaction)) {
        return true;
      }
      error = Error("DEPRECATED: 'initValues' treats Reactions normally now!");
      try {
        throwFailure(error, {
          reaction: reaction,
          key: key,
          component: _this
        });
      } catch (_error) {}
      return false;
    };
  })(this));
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
};

_initReactiveValues = function(config) {
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
};

_initNativeValues = function(config) {
  var nativeValues;
  nativeValues = config.initNativeValues.call(this);
  if (nativeValues == null) {
    return;
  }
  assertType(nativeValues, Object, "nativeValues");
  this._nativeValues = {};
  return sync.each(nativeValues, (function(_this) {
    return function(value, key) {
      if (isKind(value, NativeValue)) {
        return _this.__attachNativeValue(key, value);
      } else {
        return _this.__createNativeValue(key, value);
      }
    };
  })(this));
};

_initState = function(config) {
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
};

_startReactionsWhenMounting = function(config) {
  var componentWillMount;
  componentWillMount = steal(config, "componentWillMount", emptyFunction);
  return config.componentWillMount = function() {
    componentWillMount.call(this);
    if (this._reactions == null) {
      return;
    }
    return sync.each(this._reactions, (function(_this) {
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
  };
};

_stopReactionsWhenUnmounting = function(config) {
  var componentWillUnmount;
  componentWillUnmount = steal(config, "componentWillUnmount", emptyFunction);
  return config.componentWillUnmount = function() {
    componentWillUnmount.call(this);
    if (this._reactions == null) {
      return;
    }
    return sync.each(this._reactions, function(arg) {
      var listener, reaction;
      reaction = arg.reaction, listener = arg.listener;
      reaction.stop();
      if (listener != null) {
        return reaction.removeListener(listener);
      }
    });
  };
};

_detachNativeValuesWhenUnmounting = function() {
  var componentWillUnmount;
  componentWillUnmount = steal(config, "componentWillUnmount", emptyFunction);
  return config.componentWillUnmount = function() {
    componentWillUnmount.call(this);
    if (this._nativeValues == null) {
      return;
    }
    return sync.each(this._nativeValues, function(value) {
      return value.detach();
    });
  };
};

_addPreventableRendering = function(name, config) {
  var initReactiveValues, render, shouldComponentUpdate;
  if (config.isRenderPrevented == null) {
    return;
  }
  initReactiveValues = steal(config, "initReactiveValues", function() {
    return {};
  });
  config.initReactiveValues = function() {
    var values;
    values = initReactiveValues.call(this);
    values.willRender = false;
    values.preventRender = Reaction.sync({
      get: (function(_this) {
        return function() {
          return _this.isRenderPrevented();
        };
      })(this),
      didSet: (function(_this) {
        return function(preventRender) {
          if (preventRender) {
            return;
          }
          if (!_this.willRender) {
            return;
          }
          _this.willRender = false;
          try {
            return _this.forceUpdate();
          } catch (_error) {}
        };
      })(this)
    });
    return values;
  };
  shouldComponentUpdate = steal(config, "shouldComponentUpdate", emptyFunction.thatReturnsTrue);
  config.shouldComponentUpdate = function(props, state) {
    if (this.preventRender) {
      this.willRender = true;
      return false;
    }
    return shouldComponentUpdate.call(this, props, state);
  };
  render = steal(config, "render");
  return config.render = function() {
    if (this.preventRender) {
      this.willRender = true;
      return false;
    } else {
      return render.call(this);
    }
  };
};

_catchErrorsWhenRendering = function(config) {
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
};

_enforcePropValidation = function(name, config, statics) {
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
    value: propTypes
  };
  statics.propDefaults = {
    value: propDefaults
  };
  return statics._processProps = function(props) {
    var error, stack;
    if (propDefaults != null) {
      if (isType(props, Object)) {
        _mergeDefaults(props, propDefaults);
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
        stack = _getElementStack(error, this);
        try {
          throwFailure(error, {
            method: name + "._processProps",
            element: this,
            props: props,
            propTypes: propTypes,
            stack: stack
          });
        } catch (_error) {}
      }
    }
    return props;
  };
};

_mergeDefaults = function(values, defaultValues) {
  var defaultValue, key, value;
  for (key in defaultValues) {
    defaultValue = defaultValues[key];
    value = values[key];
    if (isType(defaultValue, Object)) {
      if (isType(value, Object)) {
        _mergeDefaults(value, defaultValue);
      } else if (value === void 0) {
        values[key] = combine({}, defaultValue);
      }
    } else if (value === void 0) {
      values[key] = defaultValue;
    }
  }
};

//# sourceMappingURL=../../map/src/Component.map
