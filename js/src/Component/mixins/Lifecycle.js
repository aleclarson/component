var assert, assertType, define, emptyFunction, guard, instancePhases, methodsByPhase, ref, sync, typeMethods, typePhases, typeValues;

require("isDev");

ref = require("type-utils"), assert = ref.assert, assertType = ref.assertType;

emptyFunction = require("emptyFunction");

define = require("define");

guard = require("guard");

sync = require("sync");

methodsByPhase = {
  willMount: "componentWillMount",
  didMount: "componentDidMount",
  willReceiveProps: "componentWillReceiveProps",
  willUpdate: "componentWillUpdate",
  didUpdate: "componentDidUpdate",
  willUnmount: "componentWillUnmount"
};

module.exports = function(type) {
  type.willBuild(typePhases.willBuild);
  type.initInstance(typePhases.initInstance);
  type.defineValues(typeValues);
  return type.defineMethods(typeMethods);
};

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
    this._render = function(props) {
      return guard((function(_this) {
        return function() {
          return render.call(_this, props);
        };
      })(this)).fail((function(_this) {
        return function(error) {
          var element, method, stack;
          if (isDev) {
            element = _this._reactInternalInstance._currentElement;
            stack = element._trace();
          }
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
  }
};

typePhases = {
  willBuild: function() {
    var lifecycle;
    lifecycle = {};
    sync.each(methodsByPhase, function(phaseName, methodName) {
      return lifecycle[methodName] = function(fn) {
        assertType(fn, Function);
        this._phases[phaseName].push(fn);
      };
    });
    return type.defineMethods(lifecycle);
  },
  initInstance: function() {
    combine(this._phases, {
      willMount: [],
      didMount: [],
      willReceiveProps: [],
      willUpdate: [],
      didUpdate: [],
      willUnmount: []
    });
    return this.willBuild(instancePhases.willBuild);
  }
};

instancePhases = {
  willBuild: function() {
    var instanceMethods, render, shouldUpdate;
    render = this._render;
    shouldUpdate = this._shouldUpdate;
    instanceMethods = {
      render: function() {
        return render.call(this.context, this.view.props);
      },
      componentShouldUpdate: function() {
        return shouldUpdate.call(this.context);
      }
    };
    sync.each(methodsByPhase, (function(_this) {
      return function(methodName, phaseName) {
        var callback, callbacks, method;
        callbacks = _this._phases[phaseName];
        if (callbacks.length === 0) {
          return;
        }
        if (callbacks.length === 1) {
          callback = callbacks;
          method = function() {
            callback.call(this.context);
          };
        } else {
          method = function() {
            var context, i, len;
            context = this.context;
            for (i = 0, len = callbacks.length; i < len; i++) {
              callback = callbacks[i];
              callback.call(context);
            }
          };
        }
        return methods[methodName] = method;
      };
    })(this));
    return this._viewType.defineMethods(methods);
  }
};

//# sourceMappingURL=../../../../map/src/Component/mixins/Lifecycle.map
