var Builder, Component, ReactComponent, ReactCurrentOwner, ReactElement, Type, sync, type;

ReactCurrentOwner = require("ReactCurrentOwner");

ReactComponent = require("ReactComponent");

ReactElement = require("ReactElement");

Builder = require("Builder");

Type = require("Type");

sync = require("sync");

Component = require(".");

type = Type("ComponentBuilder");

type.defineValues({
  _hasReactions: false,
  _hasNativeValues: false,
  _hasListeners: false,
  _viewType: function() {
    type = Type();
    type.inherits(ReactComponent);
    return type;
  },
  _phases: function() {
    return {
      willBuild: [],
      didBuild: []
    };
  }
});

type.addMixins([require("./mixins/Props"), require("./mixins/Styles"), require("./mixins/GatedRender"), require("./mixins/Lifecycle")]);

type.initInstance(function() {
  this.initInstance(function() {
    return this.context.view = this;
  });
  return this.willBuild(function() {
    return this.willUnmount(function() {
      return this.context.view = null;
    });
  });
});

type.willBuild(function() {
  var keys, methods;
  methods = {};
  keys = ["defineValues", "defineFrozenValues", "defineReactiveValues"];
  sync.each(keys, function(key) {
    return methods[key] = function(values) {
      values = sync.map(values, function(value) {
        if (!isType(value, Function)) {
          return value;
        }
        return function() {
          return value.apply(this.context, arguments);
        };
      });
      return this._viewType[key](values);
    };
  });
  return type.defineMethods(methods);
});

type.defineMethods({
  createListeners: function(fn) {
    assertType(fn, Function);
    if (!this._hasListeners) {
      this._hasListeners = true;
      this._initInstance(function() {
        return define(this, "__listeners", []);
      });
      this.willUnmount(function() {
        var i, len, listener, ref;
        ref = this.__listeners;
        for (i = 0, len = ref.length; i < len; i++) {
          listener = ref[i];
          listener.stop();
        }
      });
    }
    return this._initInstance(function(args) {
      var onListen;
      onListen = Event.didListen((function(_this) {
        return function(event, listener) {
          return _this.__listeners.push(listener);
        };
      })(this));
      fn.apply(this, args);
      return onListen.stop();
    });
  },
  defineNativeValues: function(values) {
    var dynamicValues, prop;
    assertType(values, Object);
    if (!this._hasNativeValues) {
      this._hasNativeValues = true;
      this._initInstance(function() {
        return define(this, "__nativeValues", Object.create(null));
      });
      this.willMount(function() {
        var key, nativeValue, ref;
        ref = this.__nativeValues;
        for (key in ref) {
          nativeValue = ref[key];
          nativeValue.__attach();
        }
      });
      this.willUnmount(function() {
        var key, nativeValue, ref;
        ref = this.__nativeValues;
        for (key in ref) {
          nativeValue = ref[key];
          nativeValue.__detach();
        }
      });
    }
    prop = Property({
      frozen: true
    });
    dynamicValues = Object.create(null);
    sync.each(values, function(value, key) {
      if (!isType(value, Function)) {
        return;
      }
      return dynamicValues[key] = true;
    });
    return this._initInstance(function(args) {
      var key, nativeValue, value;
      for (key in values) {
        value = values[key];
        if (dynamicValues[key]) {
          value = value.apply(this, args);
        }
        if (value === void 0) {
          continue;
        }
        if (!isType(value, NativeValue.Kind)) {
          nativeValue = NativeValue(value, this.constructor.name + "." + key);
        } else {
          nativeValue = value;
        }
        this.__nativeValues[key] = nativeValue;
        prop.define(this, key, nativeValue);
      }
    });
  },
  defineReactions: function(reactions) {
    var prop;
    assertType(reactions, Object);
    if (!this._hasReactions) {
      this._hasReactions = true;
      this._initInstance(function() {
        return define(this, "__reactions", Object.create(null));
      });
      this.willMount(function() {
        var component, key, reaction, ref;
        component = this;
        ref = this.__reactions;
        for (key in ref) {
          reaction = ref[key];
          guard(function() {
            return reaction.start();
          }).fail(function(error) {
            return throwFailure(error, {
              key: key,
              reaction: reaction,
              component: component
            });
          });
        }
      });
      this.willUnmount(function() {
        var key, reaction, ref;
        ref = this.__reactions;
        for (key in ref) {
          reaction = ref[key];
          reaction.stop();
        }
      });
    }
    prop = Property({
      frozen: true
    });
    return this._initInstance(function(args) {
      var createReaction, key, value;
      Reaction.inject.push("autoStart", true);
      for (key in reactions) {
        createReaction = reactions[key];
        assertType(createReaction, Function, key);
        value = createReaction.apply(this, args);
        if (value === void 0) {
          continue;
        }
        if (!isType(value, Reaction)) {
          value = Reaction.sync(value);
        }
        assert(this.__reactions[key] === void 0, {
          reason: "Conflicting reactions are both named '" + key + "'."
        });
        this.__reactions[key] = value;
        prop.define(this, key, value);
      }
      return Reaction.inject.pop("autoStart");
    });
  },
  defineProperties: function(props) {
    var bound;
    bound = ["get", "set", "willSet", "didSet", "lazy"];
    sync.each(props, function(prop) {
      return sync.each(bound, function(key) {
        var func;
        func = prop[key];
        if (!isType(func, Function)) {
          return;
        }
        return prop[key] = function() {
          return func.apply(this.context, arguments);
        };
      });
    });
    return this._viewType.defineProperties(props);
  },
  defineMethods: function(methods) {
    methods = sync.map(methods, function(method, key) {
      return function() {
        return method.apply(this.context, arguments);
      };
    });
    return this._viewType.defineMethods(methods);
  },
  initInstance: function(init) {
    return this._viewType.initInstance(init);
  },
  willBuild: Builder.prototype.willBuild,
  didBuild: Builder.prototype.didBuild,
  build: function() {
    var i, j, len, len1, phase, ref, ref1;
    if (this._phases.willBuild.length) {
      ref = this._phases.willBuild;
      for (i = 0, len = ref.length; i < len; i++) {
        phase = ref[i];
        phase.call(this);
      }
    }
    type = this.__createType(this._viewType.build());
    if (this._phases.didBuild.length) {
      ref1 = this._phases.didBuild;
      for (j = 0, len1 = ref1.length; j < len1; j++) {
        phase = ref1[j];
        phase.call(null, this);
      }
    }
    return type;
  },
  _initInstance: function(init) {
    return this._viewType._initInstance(init);
  },
  __createType: function(type) {
    var factory;
    factory = this.__createFactory(type);
    factory.type = type;
    return factory;
  },
  __createFactory: function(type) {
    return function(props) {
      var addProp, element, i, key, len, mixin, mixins, ref;
      if (props == null) {
        props = {};
      }
      if (props.mixins != null) {
        mixins = steal(props, "mixins");
        assertType(mixins, Array, "props.mixins");
        addProp = function(key, value) {
          if (props[key] !== void 0) {
            return;
          }
          return props[key] = value;
        };
        ref = props.mixin;
        for (i = 0, len = ref.length; i < len; i++) {
          mixin = ref[i];
          sync.each(mixin, addProp);
        }
      }
      key = null;
      if (props.key != null) {
        key = steal(props, "key");
        if (!isType(key, String)) {
          key = "" + key;
        }
      }
      element = {
        type: type,
        key: key,
        props: props,
        $$typeof: ReactElement.type
      };
      define(element, {
        _owner: ReactCurrentOwner.current,
        _store: {
          value: {
            validated: false
          }
        },
        _trace: isDev ? Tracer("ReactElement()") : void 0
      });
      return element;
    };
  }
});

module.exports = type.build();

//# sourceMappingURL=../../../map/src/Component/Builder.map
