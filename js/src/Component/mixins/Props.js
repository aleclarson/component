var instancePhases, typeMethods, typePhases, typeProps, typeValues;

module.exports = function(type) {
  type.defineValues(typeValues);
  type.defineProperties(typeProps);
  type.defineMethods(typeMethods);
  return type.initInstance(typePhases.initInstance);
};

typeValues = {
  _contextType: null,
  _propTypes: null,
  _propDefaults: null
};

typeProps = {
  contextType: {
    get: function() {
      return this._contextType;
    },
    set: function(contextType) {
      assert(!this._contextType, "'contextType' is already defined!");
      this._contextType = contextType;
      return this._viewType;
    }
  },
  propTypes: {
    get: function() {
      return this._propTypes;
    },
    set: function(propTypes) {
      assert(!this._propTypes, "'propTypes' is already defined!");
      assertType(propTypes, Object);
      this._propTypes = propTypes;
      this.initType(function(type) {
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
      assert(!this._propDefaults, "'propDefaults' is already defined!");
      assertType(propDefaults, Object);
      this._propDefaults = propDefaults;
      this.initType(function(type) {
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
  }
};

typeMethods = {
  createProps: function(fn) {
    assertType(fn, Function);
    this._phases.initProps.unshift(fn);
  },
  initProps: function(fn) {
    assertType(fn, Function);
    this._phases.initProps.push(fn);
  }
};

typePhases = {
  initInstance: function() {
    this._phases.initProps = [];
    return this.willBuild(instancePhases.willBuild);
  }
};

instancePhases = {
  willBuild: function() {
    var phase, phases, processProps;
    phases = this._phases.initProps;
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
    return this._viewType.initType(function(type) {
      return define(type, "_processProps", processProps);
    });
  }
};

//# sourceMappingURL=../../../../map/src/Component/mixins/Props.map
