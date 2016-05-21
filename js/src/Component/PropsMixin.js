var assert, assertType, define, guard, instancePhases, mergeDefaults, typePhases, typePrototype, typeValues;

mergeDefaults = require("mergeDefaults");

assertType = require("assertType");

assert = require("assert");

define = require("define");

guard = require("guard");

module.exports = function(type) {
  type.defineValues(typeValues);
  type.definePrototype(typePrototype);
  return type.initInstance(typePhases.initInstance);
};

typeValues = {
  _propTypes: null,
  _propDefaults: null,
  _initProps: function() {
    return [];
  }
};

typePrototype = {
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

typePhases = {
  initInstance: function() {
    return this._willBuild.push(instancePhases.willBuild);
  }
};

instancePhases = {
  willBuild: function() {
    var phase, phases, processProps;
    phases = this._initProps;
    if (phases.length === 0) {
      return;
    }
    if (phases.length === 1) {
      phase = phases[0];
      processProps = function(props) {
        return phase.call(null, props);
      };
    } else {
      processProps = function(props) {
        var i, len;
        for (i = 0, len = phases.length; i < len; i++) {
          phase = phases[i];
          props = phase.call(null, props);
        }
        return props;
      };
    }
    return this._didBuild.push(function(type) {
      return define(type, "_processProps", processProps);
    });
  }
};

//# sourceMappingURL=../../../map/src/Component/PropsMixin.map
