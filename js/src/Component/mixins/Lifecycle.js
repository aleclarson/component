var assert, assertType, guard, instancePhases, phaseNames, shimNames, sync, typeMethods, typePhases, typeValues;

require("isDev");

assertType = require("assertType");

assert = require("assert");

guard = require("guard");

sync = require("sync");

module.exports = function(type) {
  type.initInstance(typePhases.initInstance);
  type.defineValues(typeValues);
  return type.defineMethods(typeMethods);
};

shimNames = {
  willMount: "componentWillMount",
  didMount: "componentDidMount",
  willReceiveProps: "componentWillReceiveProps",
  willUpdate: "componentWillUpdate",
  didUpdate: "componentDidUpdate",
  willUnmount: "componentWillUnmount"
};

phaseNames = Object.keys(shimNames);

typeValues = {
  _render: function() {
    return emptyFunction.thatReturnsFalse;
  },
  _shouldUpdate: function() {
    return emptyFunction.thatReturnsTrue;
  }
};

typeMethods = {
  shouldUpdate: function(shouldUpdate) {
    assert(!this._shouldUpdate, "'shouldUpdate' is already defined!");
    assertType(shouldUpdate, Function);
    this._shouldUpdate = shouldUpdate;
  },
  render: function(render) {
    assertType(render, Function);
    assert(!this._render, "'render' is already defined!");
    if (isDev) {
      this._render = function(props) {
        return guard((function(_this) {
          return function() {
            return render.call(_this, props);
          };
        })(this)).fail((function(_this) {
          return function(error) {
            var element, method, stack;
            element = _this._reactInternalInstance._currentElement;
            stack = element._trace();
            method = _this.constructor.name + ".render";
            throwFailure(error, {
              context: _this,
              method: method,
              stack: stack
            });
            return false;
          };
        })(this));
      };
    } else {
      this._render = render;
    }
  }
};

sync.each(phaseNames, function(phaseName) {
  return typeMethods[phaseName] = function(fn) {
    assertType(fn, Function);
    this._phases[phaseName].push(fn);
  };
});

typePhases = {
  initInstance: function() {
    var i, len, phaseName;
    for (i = 0, len = phaseNames.length; i < len; i++) {
      phaseName = phaseNames[i];
      this._phases[phaseName] = [];
    }
    return this.willBuild(instancePhases.willBuild);
  }
};

instancePhases = {
  willBuild: function() {
    var render, shims, shouldUpdate;
    render = this._render;
    shouldUpdate = this._shouldUpdate;
    shims = {
      render: function() {
        return render.call(this.context, this.view.props);
      },
      componentShouldUpdate: function() {
        return shouldUpdate.call(this.context);
      }
    };
    sync.each(shimNames, (function(_this) {
      return function(shimName, phaseName) {
        var callback, callbacks, shim;
        callbacks = _this._phases[phaseName];
        if (callbacks.length === 0) {
          return;
        }
        if (callbacks.length === 1) {
          callback = callbacks;
          shim = function() {
            callback.call(this.context);
          };
        } else {
          shim = function() {
            var context, i, len;
            context = this.context;
            for (i = 0, len = callbacks.length; i < len; i++) {
              callback = callbacks[i];
              callback.call(context);
            }
          };
        }
        return shims[shimName] = shim;
      };
    })(this));
    return this._viewType.defineMethods(shims);
  }
};

//# sourceMappingURL=../../../../map/src/Component/mixins/Lifecycle.map
