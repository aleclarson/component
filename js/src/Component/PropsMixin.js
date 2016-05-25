var ReactComponent, assert, assertType, define, getKind, guard, has, instImpl, mergeDefaults, superWrap, typeImpl;

ReactComponent = require("ReactComponent");

mergeDefaults = require("mergeDefaults");

assertType = require("assertType");

getKind = require("getKind");

define = require("define");

assert = require("assert");

guard = require("guard");

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
      assert(!this._propTypes, "'propTypes' is already defined!");
      this._propTypes = propTypes;
      this._didBuild.push(function(type) {
        return type.propTypes = propTypes;
      });
      if (!this._propDefaults) {
        this.createProps(function(props) {
          return props || {};
        });
      }
      return this.initProps(function(props) {
        if (isDev) {
          return;
        }
        assertType(props, Object);
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
        return props;
      });
    }
  },
  propDefaults: {
    get: function() {
      return this._propDefaults;
    },
    set: function(propDefaults) {
      assertType(propDefaults, Object);
      assert(!this._propDefaults, "'propDefaults' is already defined!");
      this._propDefaults = propDefaults;
      this._didBuild.push(function(type) {
        return type.propDefaults = propDefaults;
      });
      if (!this._propTypes) {
        this.createProps(function(props) {
          return props || {};
        });
      }
      return this.initProps(function(props) {
        assertType(props, Object);
        mergeDefaults(props, propDefaults);
        return props;
      });
    }
  },
  createProps: function(fn) {
    assertType(fn, Function);
    this._initProps.unshift(fn);
  },
  initProps: function(fn) {
    assertType(fn, Function);
    this._initProps.push(fn);
  }
};

typeImpl.initInstance = function() {
  return this._willBuild.push(instImpl.willBuild);
};

instImpl = {};

instImpl.willBuild = function() {
  var phases, processProps, superImpl;
  this._didBuild.push((function(_this) {
    return function() {
      return _this._didBuild.push(instImpl.didBuild);
    };
  })(this));
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
    return this._didBuild.push(function(type) {
      return define(type.prototype, "_processProps", processProps);
    });
  }
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
    props = processProps(props);
    return superImpl(props);
  };
};

//# sourceMappingURL=../../../map/src/Component/PropsMixin.map
