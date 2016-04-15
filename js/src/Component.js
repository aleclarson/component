var Component, Event, ExceptionsManager, Injector, Maybe, NamedFunction, NativeValue, Random, ReactComponent, ReactCurrentOwner, ReactElement, Reaction, ReactionInjector, ReactiveGetter, StyleSheet, assertType, combine, define, emptyFunction, flattenStyle, guard, hook, isType, mergeDefaults, ref1, setKind, setType, steal, sync, throwFailure, validateTypes;

require("isDev");

ref1 = require("type-utils"), Maybe = ref1.Maybe, setKind = ref1.setKind, setType = ref1.setType, isType = ref1.isType, assertType = ref1.assertType, validateTypes = ref1.validateTypes;

throwFailure = require("failure").throwFailure;

ReactCurrentOwner = require("ReactCurrentOwner");

ExceptionsManager = require("ExceptionsManager");

ReactiveGetter = require("ReactiveGetter");

ReactComponent = require("ReactComponent");

NamedFunction = require("NamedFunction");

emptyFunction = require("emptyFunction");

mergeDefaults = require("mergeDefaults");

ReactElement = require("ReactElement");

flattenStyle = require("flattenStyle");

StyleSheet = require("StyleSheet");

Reaction = require("reaction");

Injector = require("injector");

combine = require("combine");

define = require("define");

Random = require("random");

Event = require("event");

guard = require("guard");

steal = require("steal");

sync = require("sync");

hook = require("hook");

ReactionInjector = Injector("Reaction");

NativeValue = require("./NativeValue");

Component = NamedFunction("Component", function(name, config) {
  var factory, styles, type;
  assertType(name, String, "name");
  assertType(config, Object, "config");
  Component.applyMixins(config, name);
  validateTypes(config, Component.configTypes);
  type = Component.createType(config, name);
  factory = Component.createFactory(type);
  styles = Component.createStyles(config);
  define(factory, Component.createStatics(config, type, styles));
  define(type.prototype, Component.createPrototype(config, styles));
  return factory;
});

module.exports = setKind(Component, ReactComponent);

define(Component, {
  configTypes: {
    value: {
      propTypes: Object.Maybe,
      propDefaults: Object.Maybe,
      events: Array.Maybe,
      boundMethods: Array.Maybe,
      customValues: Object.Maybe,
      init: Function.Maybe,
      initProps: Function.Maybe,
      initState: Function.Maybe,
      initValues: Function.Maybe,
      initReactiveValues: Function.Maybe,
      initNativeValues: Function.Maybe,
      initListeners: Function.Maybe,
      isRenderPrevented: Maybe(Function.Kind),
      render: Function.Kind,
      styles: Object.Maybe,
      statics: Object.Maybe,
      mixins: Array.Maybe
    }
  },
  applyMixins: function(config, name) {
    var mixins;
    mixins = steal(config, "mixins", []);
    sync.each(mixins, function(mixin, key) {
      assertType(mixin, Function, {
        name: name,
        key: key,
        mixin: mixin,
        mixins: mixins
      });
      return mixin(config, name);
    });
    return sync.each(Component.mixins, function(mixin, key) {
      assertType(mixin, Function, {
        name: name,
        key: key,
        mixin: mixin,
        mixins: mixins
      });
      return mixin(config, name);
    });
  },
  createStyles: function(config) {
    if (!config.styles) {
      return;
    }
    return StyleSheet.create(steal(config, "styles"));
  },
  createStatics: function(config, type, styles) {
    var statics;
    statics = steal(config, "statics", {});
    statics.type = type;
    if (styles) {
      statics.styles = {
        value: styles
      };
    }
    return sync.map(statics, function(value, key) {
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
  },
  createPrototype: function(config, styles) {
    if (styles) {
      config.styles = styles;
    }
    return sync.map(config, function(value, key) {
      return {
        configurable: false,
        enumerable: key[0] !== "_",
        value: value
      };
    });
  },
  createType: function(config, name) {
    var initPhases, type;
    initPhases = {};
    sync.each(Component.initPhases, function(createPhase, key) {
      var initPhase;
      initPhase = createPhase(config, name);
      if (initPhase) {
        return initPhases[key] = initPhase;
      }
    });
    type = NamedFunction(name, function(props) {
      var component;
      component = setType({
        props: props
      }, type);
      guard(function() {
        return Component.initialize(component, initPhases);
      }).fail(function(error) {
        return throwFailure(error, {
          component: component,
          props: props,
          stack: isDev ? props.__trace() : void 0
        });
      });
      return component;
    });
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
      if (props.mixins) {
        mixins = steal(props, "mixins");
        assertType(mixins, Array, "props.mixins");
        props = combine.apply(null, [{}].concat(mixins.concat(props)));
      }
      key = props.key ? "" + props.key : null;
      delete props.key;
      ref = props.ref ? props.ref : null;
      delete props.ref;
      if (isDev) {
        props.__trace = Tracer("When element was created");
      }
      return {
        type: type,
        key: key,
        ref: ref,
        props: props,
        $$typeof: ReactElement.type,
        _owner: ReactCurrentOwner.current,
        _store: {
          validated: false
        }
      };
    };
  },
  initialize: function(component, initPhases) {
    return sync.each(initPhases, function(init, key) {
      return guard(function() {
        return init.call(component);
      }).fail(function(error) {
        return throwFailure(error, {
          component: component,
          key: key,
          init: init
        });
      });
    });
  },
  mixins: {
    value: {
      enforcePropValidation: function(config, name) {
        var events, initProps, propDefaults, propTypes, statics;
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
            propTypes[event] = Function.Maybe;
            return propDefaults[event] = emptyFunction;
          });
        }
        statics = config.statics != null ? config.statics : config.statics = {};
        statics.propTypes = {
          value: propTypes,
          frozen: false
        };
        statics.propDefaults = {
          value: propDefaults
        };
        return statics._processProps = function(props) {
          if (propDefaults) {
            if (props == null) {
              props = {};
            }
            mergeDefaults(props, propDefaults);
          }
          initProps.call(this, props);
          if (isDev && propTypes && isType(props, Object)) {
            guard(function() {
              return validateTypes(props, propTypes);
            }).fail(function(error) {
              return throwFailure(error, {
                method: "_processProps",
                element: this,
                props: props,
                propTypes: propTypes
              });
            });
          }
          return props;
        };
      },
      addPreventableRendering: function(config, name) {
        var isRenderPrevented, render, shouldUpdate;
        isRenderPrevented = steal(config, "isRenderPrevented");
        if (!isRenderPrevented) {
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
          return define(this, {
            enumerable: false
          }, {
            __needsRender: {
              value: false
            },
            __shouldRender: {
              get: function() {
                return shouldRender.value;
              }
            }
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
      catchErrorsWhenRendering: function(config, name) {
        var render, renderSafely;
        render = steal(config, "render");
        renderSafely = function() {
          return guard((function(_this) {
            return function() {
              return render.call(_this);
            };
          })(this)).fail((function(_this) {
            return function(error) {
              var element;
              element = _this._reactInternalInstance._currentElement;
              throwFailure(error, {
                method: _this.constructor.name + ".render",
                component: _this,
                stack: isDev ? element.props.__trace() : void 0
              });
              return false;
            };
          })(this));
        };
        renderSafely.toString = function() {
          return render.toString();
        };
        return config.render = renderSafely;
      },
      startReactionsWhenMounting: function(config) {
        return hook.after(config, "componentWillMount", function() {
          var component;
          if (!this.__reactions) {
            return;
          }
          component = this;
          return sync.each(this.__reactions, function(arg, key) {
            var listener, reaction;
            reaction = arg.reaction, listener = arg.listener;
            return guard(function() {
              return reaction.start();
            }).fail(function(error) {
              return throwFailure(error, {
                key: key,
                reaction: reaction,
                component: component
              });
            });
          });
        });
      },
      stopReactionsWhenUnmounting: function(config) {
        return hook.after(config, "componentWillUnmount", function() {
          if (!this.__reactions) {
            return;
          }
          return sync.each(this.__reactions, function(arg) {
            var listener, reaction;
            reaction = arg.reaction, listener = arg.listener;
            if (listener) {
              listener.stop();
            }
            return reaction.release();
          });
        });
      },
      stopListenersWhenUnmounting: function(config) {
        if (!config.initListeners) {
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
          if (!this.__nativeValues) {
            return;
          }
          return sync.each(this.__nativeValues, function(value) {
            return value.detach();
          });
        });
      }
    }
  },
  initPhases: {
    value: {
      boundMethods: function(config) {
        var boundMethods;
        if (!config.boundMethods) {
          return;
        }
        boundMethods = steal(config, "boundMethods");
        return function() {
          var values;
          values = {};
          sync.each(boundMethods, (function(_this) {
            return function(key) {
              var method;
              method = _this[key];
              if (!(method && method.apply)) {
                return;
              }
              return values[key] = {
                enumerable: key[0] !== "_",
                value: function() {
                  return method.apply(_this, arguments);
                }
              };
            };
          })(this));
          return define(this, values);
        };
      },
      customValues: function(config) {
        var customValues;
        if (!config.customValues) {
          return;
        }
        customValues = steal(config, "customValues");
        return function() {
          return define(this, customValues);
        };
      },
      initValues: function(config) {
        var initValues;
        if (!config.initValues) {
          return;
        }
        initValues = steal(config, "initValues");
        return function() {
          var values;
          values = initValues.call(this);
          if (!values) {
            return;
          }
          assertType(values, Object);
          return define(this, sync.map(values, function(value, key) {
            return {
              value: value,
              enumerable: key[0] !== "_"
            };
          }));
        };
      },
      initReactiveValues: function(config) {
        var initReactiveValues;
        if (!config.initReactiveValues) {
          return;
        }
        initReactiveValues = steal(config, "initReactiveValues");
        return function() {
          var values;
          values = initReactiveValues.call(this);
          if (!values) {
            return;
          }
          assertType(values, Object);
          return define(this, sync.map(values, function(value, key) {
            return {
              enumerable: key[0] !== "_",
              reactive: true,
              value: value
            };
          }));
        };
      },
      initNativeValues: function(config) {
        var initNativeValues;
        if (!config.initNativeValues) {
          return;
        }
        initNativeValues = steal(config, "initNativeValues");
        return function() {
          var values;
          ReactionInjector.push("autoStart", false);
          values = initNativeValues.call(this);
          ReactionInjector.pop("autoStart");
          if (!values) {
            return;
          }
          assertType(values, Object);
          define(this, "__nativeValues", {
            value: {},
            enumerable: false
          });
          return sync.each(values, (function(_this) {
            return function(value, key) {
              if (isType(value, NativeValue.Kind)) {
                return _this.__attachNativeValue(key, value);
              } else {
                return _this.__createNativeValue(key, value);
              }
            };
          })(this));
        };
      },
      initState: function(config) {
        var initState;
        if (!config.initState) {
          return;
        }
        initState = steal(config, "initState");
        return function() {
          var state;
          state = initState.call(this);
          if (!state) {
            return;
          }
          assertType(state, Object);
          return this.state = state;
        };
      },
      initReactions: function(config) {
        var initReactions, optionCreators;
        if (!config.initReactions) {
          return;
        }
        initReactions = steal(config, "initReactions");
        optionCreators = initReactions();
        assertType(optionCreators, Object);
        return function() {
          var values;
          values = {};
          ReactionInjector.push("autoStart", false);
          sync.each(optionCreators, (function(_this) {
            return function(createOptions, key) {
              var options, value;
              options = createOptions.call(_this);
              if (!options) {
                return;
              }
              if (isType(options, Function.Kind)) {
                options = {
                  get: options
                };
              }
              if (isType(options, Object)) {
                if (options.sync == null) {
                  options.sync = true;
                }
                value = Reaction(options);
              } else {
                value = options;
              }
              if (isType(value, Reaction)) {
                _this.__addReaction(key, value);
              }
              return values[key] = {
                value: value,
                enumerable: key[0] !== "_"
              };
            };
          })(this));
          ReactionInjector.pop("autoStart");
          return define(this, values);
        };
      },
      initListeners: function(config) {
        var initListeners;
        if (!config.initListeners) {
          return;
        }
        initListeners = steal(config, "initListeners");
        return function() {
          var onListen;
          define(this, "__listeners", {
            value: [],
            enumerable: false
          });
          onListen = Event.didListen((function(_this) {
            return function(event, listener) {
              return _this.__listeners.push(listener);
            };
          })(this));
          initListeners.call(this);
          return onListen.stop();
        };
      },
      init: function(config) {
        return steal(config, "init");
      }
    }
  }
});

define(Component.prototype, {
  enumerable: false
}, {
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
    if (!this.__reactions) {
      define(this, "__reactions", {
        value: {},
        enumerable: false
      });
    }
    assert(this.__reactions[key] === void 0, "Conflicting reactions are both named '" + key + "'.");
    if (listener) {
      listener = reaction.didSet(listener);
    }
    this.__reactions[key] = {
      reaction: reaction,
      listener: listener
    };
  },
  __attachNativeValue: function(key, nativeValue) {
    assertType(nativeValue, NativeValue.Kind);
    this.__nativeValues[key] = nativeValue;
    define(this, key, {
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
      this.__addReaction(key, nativeValue._reaction);
    }
  }
});

//# sourceMappingURL=../../map/src/Component.map
