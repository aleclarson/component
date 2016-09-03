var ReactComponent, ReactCompositeComponent, assertType, frozen, getKind, has, hasKeys, hook, instImpl, isType, mutable, ref, superWrap, sync, typeImpl;

require("isDev");

ref = require("Property"), mutable = ref.mutable, frozen = ref.frozen;

ReactComponent = require("ReactComponent");

assertType = require("assertType");

getKind = require("getKind");

hasKeys = require("hasKeys");

isType = require("isType");

sync = require("sync");

hook = require("hook");

has = require("has");

module.exports = function(type) {
  type.defineMethods(typeImpl.defineMethods);
  return type.initInstance(typeImpl.initInstance);
};

ReactCompositeComponent = require("ReactCompositeComponent");

ReactCompositeComponent.Mixin._processProps = function(props) {
  var processProps;
  if (props == null) {
    props = {};
  }
  processProps = this._currentElement.type.prototype.processProps;
  if (processProps) {
    return processProps(props);
  } else {
    return props;
  }
};

typeImpl = {
  defineMethods: {
    defineProps: function(props) {
      var propDefaults, propNames, propTypes, requiredTypes;
      assertType(props, Object);
      if (this._argTypes) {
        throw Error("'argTypes' is already defined!");
      }
      propNames = [];
      propTypes = {};
      propDefaults = {};
      requiredTypes = {};
      sync.each(props, function(prop, name) {
        var propType;
        propNames.push(name);
        if (!isType(prop, Object)) {
          propTypes[name] = prop;
          return;
        }
        if (has(prop, "default")) {
          propDefaults[name] = prop["default"];
        }
        if (propType = prop.type) {
          if (isType(propType, Object)) {
            propType = Shape(propType);
          }
          if (prop.required) {
            requiredTypes[name] = true;
          }
          return propTypes[name] = propType;
        }
      });
      frozen.define(this, "_propTypes", {
        value: propTypes
      });
      this.didBuild(function(type) {
        if (hasKeys(propTypes)) {
          type.propTypes = propTypes;
        }
        if (hasKeys(propDefaults)) {
          return type.propDefaults = propDefaults;
        }
      });
      this._phases.props.push(function(props) {
        var i, len, name, prop, propType;
        for (i = 0, len = propNames.length; i < len; i++) {
          name = propNames[i];
          prop = props[name];
          if (prop === void 0) {
            if (propDefaults[name] !== void 0) {
              props[name] = prop = propDefaults[name];
            } else if (!requiredTypes[name]) {
              continue;
            }
          }
          if (isDev) {
            propType = propTypes[name];
            propType && assertType(prop, propType, "props." + name);
          }
        }
        return props;
      });
    },
    replaceProps: function(func) {
      assertType(func, Function);
      this._phases.props.unshift(func);
    },
    initProps: function(func) {
      assertType(func, Function);
      this._phases.props.push(function(props) {
        func.call(this, props);
        return props;
      });
    }
  },
  initInstance: function() {
    this._phases.props = [];
    this.initInstance(instImpl.initInstance);
    return this.willBuild(instImpl.willBuild);
  }
};

instImpl = {
  initInstance: function() {
    var delegate;
    delegate = this._delegate;
    if (delegate !== this) {
      delegate._props = this.props;
    }
  },
  willReceiveProps: function(orig, props) {
    var delegate;
    orig.call(this, props);
    if (delegate = props.delegate) {
      delegate._props = props;
    }
  },
  willBuild: function(type) {
    var processProps, propPhases, superImpl;
    propPhases = this._phases.props;
    if (propPhases.length) {
      processProps = function(props) {
        var i, len, phase;
        for (i = 0, len = propPhases.length; i < len; i++) {
          phase = propPhases[i];
          props = phase.call(null, props);
        }
        return props;
      };
    }
    if (superImpl = this._kind && this._kind.prototype._processProps) {
      processProps = superWrap(processProps, superImpl);
    }
    processProps && this.didBuild(function(type) {
      return frozen.define(type.prototype, "_processProps", {
        value: processProps
      });
    });
    hook(this, "_willReceiveProps", instImpl.willReceiveProps);
    return this.didBuild(instImpl.didBuild);
  },
  didBuild: function(type) {
    if (ReactComponent !== getKind(type)) {
      return;
    }
    if (has(type.prototype, "_delegate")) {
      return;
    }
    return mutable.define(type.prototype, "_delegate", {
      get: function() {
        return this;
      }
    });
  }
};

superWrap = function(processProps, superImpl) {
  if (!processProps) {
    return superImpl;
  }
  return function(props) {
    return superImpl.call(this, processProps.call(this, props));
  };
};

//# sourceMappingURL=map/PropsMixin.map
