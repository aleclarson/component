var ReactComponent, ReactCompositeComponent, assertType, assertTypes, define, emptyFunction, getKind, has, hasKeys, instImpl, isType, mergeDefaults, superWrap, sync, typeImpl;

require("isDev");

ReactComponent = require("ReactComponent");

emptyFunction = require("emptyFunction");

mergeDefaults = require("mergeDefaults");

assertTypes = require("assertTypes");

assertType = require("assertType");

getKind = require("getKind");

hasKeys = require("hasKeys");

isType = require("isType");

define = require("define");

sync = require("sync");

has = require("has");

module.exports = function(type) {
  type.defineValues(typeImpl.defineValues);
  type.defineMethods(typeImpl.defineMethods);
  return type.initInstance(typeImpl.initInstance);
};

ReactCompositeComponent = require("ReactCompositeComponent");

ReactCompositeComponent.Mixin._processProps = function(props) {
  var processProps;
  processProps = this._currentElement.type.prototype.processProps;
  if (processProps) {
    return processProps(props);
  } else {
    return props;
  }
};

typeImpl = (function() {
  return {
    defineValues: function() {
      return {
        _propPhases: []
      };
    },
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
        this._propTypes = propTypes;
        this.didBuild(function(type) {
          if (hasKeys(propTypes)) {
            type.propTypes = propTypes;
          }
          if (hasKeys(propDefaults)) {
            return type.propDefaults = propDefaults;
          }
        });
        this._propPhases.push(function(props) {
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
        this._propPhases.unshift(func);
      },
      initProps: function(func) {
        assertType(func, Function);
        this._propPhases.push(function(props) {
          func.call(this, props);
          return props;
        });
      }
    },
    initInstance: function() {
      this.initInstance(instImpl.initInstance);
      return this.willBuild(instImpl.willBuild);
    }
  };
})();

instImpl = (function() {
  return {
    initInstance: function() {
      var delegate;
      delegate = this._delegate;
      if (delegate !== this) {
        delegate._props = this.props;
      }
    },
    willBuild: function() {
      var phases, processProps, superImpl;
      phases = this._propPhases;
      if (phases.length) {
        processProps = function(props) {
          var i, len, phase;
          for (i = 0, len = phases.length; i < len; i++) {
            phase = phases[i];
            props = phase.call(null, props);
          }
          return props;
        };
      }
      if (superImpl = this._kind && this._kind.prototype._processProps) {
        processProps = superWrap(processProps, superImpl);
      }
      if (processProps) {
        this.didBuild(function(type) {
          return define(type.prototype, "_processProps", {
            value: processProps
          });
        });
      }
      return this.didBuild((function(_this) {
        return function() {
          return _this.didBuild(instImpl.didBuild);
        };
      })(this));
    },
    didBuild: function(type) {
      if (ReactComponent !== getKind(type)) {
        return;
      }
      if (has(type.prototype, "_delegate")) {
        return;
      }
      return define(type.prototype, "_delegate", {
        get: function() {
          return this;
        }
      });
    }
  };
})();

superWrap = function(processProps, superImpl) {
  if (!processProps) {
    return superImpl;
  }
  return function(props) {
    return superImpl.call(this, processProps.call(this, props));
  };
};

//# sourceMappingURL=map/PropsMixin.map
