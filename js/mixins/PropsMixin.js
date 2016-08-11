var Property, ReactComponent, assertType, assertTypes, define, getKind, has, instImpl, mergeDefaults, superWrap, typeImpl;

require("isDev");

ReactComponent = require("ReactComponent");

mergeDefaults = require("mergeDefaults");

assertTypes = require("assertTypes");

assertType = require("assertType");

Property = require("Property");

getKind = require("getKind");

define = require("define");

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
      assertType(propTypes, Object);
      if (this._propTypes) {
        throw Error("'propTypes' is already defined!");
      }
      this._propTypes = propTypes;
      this._didBuild.push(function(type) {
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
      this._didBuild.push(function(type) {
        return type.propDefaults = propDefaults;
      });
      return this.initProps(function(props) {
        return mergeDefaults(props, propDefaults);
      });
    }
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
  return this._willBuild.push(instImpl.willBuild);
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
    this._didBuild.push(function(type) {
      return define(type.prototype, "_processProps", {
        value: processProps
      });
    });
  }
  return this._didBuild.push((function(_this) {
    return function() {
      return _this._didBuild.push(instImpl.didBuild);
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
