var Property, ReactComponent, assertType, assertTypes, define, getKind, has, hasKeys, instImpl, isType, mergeDefaults, superWrap, sync, typeImpl;

require("isDev");

ReactComponent = require("ReactComponent");

mergeDefaults = require("mergeDefaults");

assertTypes = require("assertTypes");

assertType = require("assertType");

Property = require("Property");

getKind = require("getKind");

hasKeys = require("hasKeys");

isType = require("isType");

define = require("define");

sync = require("sync");

has = require("has");

module.exports = function(type) {
  type.defineValues(typeImpl.values);
  type.definePrototype(typeImpl.prototype);
  return type.initInstance(typeImpl.initInstance);
};

typeImpl = {};

typeImpl.values = {
  _propTypes: null,
  _propDefaults: null,
  _initProps: function() {
    return [];
  }
};

typeImpl.prototype = {
  propTypes: {
    get: function() {
      return this._propTypes;
    },
    set: function(propTypes) {
      console.warn("Use 'defineProps' instead of setting 'propTypes'!");
      assertType(propTypes, Object);
      if (this._propTypes) {
        throw Error("'propTypes' is already defined!");
      }
      this._propTypes = propTypes;
      this.didBuild(function(type) {
        return type.propTypes = propTypes;
      });
      if (isDev) {
        return this.initProps(function(props) {
          return assertTypes(props, propTypes);
        });
      }
    }
  },
  propDefaults: {
    get: function() {
      return this._propDefaults;
    },
    set: function(propDefaults) {
      assertType(propDefaults, Object);
      if (this._propDefaults) {
        throw Error("'propDefaults' is already defined!");
      }
      this._propDefaults = propDefaults;
      this.didBuild(function(type) {
        return type.propDefaults = propDefaults;
      });
      return this.initProps(function(props) {
        return mergeDefaults(props, propDefaults);
      });
    }
  },
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
    this._initProps.push(function(props) {
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
  createProps: function(func) {
    assertType(func, Function);
    this._initProps.unshift(func);
  },
  initProps: function(func) {
    assertType(func, Function);
    this._initProps.push(function(props) {
      func.call(this, props);
      return props;
    });
  }
};

typeImpl.initInstance = function() {
  return this.willBuild(instImpl.willBuild);
};

instImpl = {};

instImpl.willBuild = function() {
  var phases, processProps, superImpl;
  phases = this._initProps;
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
};

instImpl.didBuild = function(type) {
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
};

superWrap = function(processProps, superImpl) {
  if (!processProps) {
    return superImpl;
  }
  return function(props) {
    return superImpl(processProps(props));
  };
};

//# sourceMappingURL=map/PropsMixin.map
