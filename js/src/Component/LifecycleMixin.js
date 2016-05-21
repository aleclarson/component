var Builder, applyChain, assert, assertType, emptyFunction, guard, instanceMethods, instancePhases, sync, typeMethods, typePhases, typeValues;

require("isDev");

emptyFunction = require("emptyFunction");

assertType = require("assertType");

applyChain = require("applyChain");

Builder = require("Builder");

assert = require("assert");

guard = require("guard");

sync = require("sync");

module.exports = function(type) {
  type.defineValues(typeValues);
  type.defineMethods(typeMethods);
  return type.initInstance(typePhases.initInstance);
};

typeValues = {
  _render: function() {
    return emptyFunction.thatReturnsFalse;
  },
  _shouldUpdate: function() {
    return emptyFunction.thatReturnsTrue;
  },
  _willMount: function() {
    return [];
  },
  _didMount: function() {
    return [];
  },
  _willUnmount: function() {
    return [];
  }
};

typeMethods = {
  willMount: function(func) {
    assertType(func, Function);
    this._willMount.push(func);
  },
  didMount: function(func) {
    assertType(func, Function);
    this._didMount.push(func);
  },
  willUnmount: function(func) {
    assertType(func, Function);
    this._willUnmount.push(func);
  },
  shouldUpdate: function(func) {
    assertType(func, Function);
    this._shouldUpdate = func;
  },
  render: function(func) {
    assertType(func, Function);
    this._render = func;
  }
};

typePhases = {
  initInstance: function() {
    return this._willBuild.push(instancePhases.willBuild);
  }
};

instancePhases = {
  willBuild: function() {
    this.definePrototype({
      _willMount: this._willMount,
      _didMount: this._didMount,
      _willUnmount: this._willUnmount
    });
    this.defineMethods(instanceMethods);
    return this.defineMethods({
      shouldComponentUpdate: this._shouldUpdate,
      render: this._render
    });
  }
};

instanceMethods = {
  componentWillMount: function() {
    return applyChain(this._willMount, this);
  },
  componentDidMount: function() {
    return applyChain(this._didMount, this);
  },
  componentWillUnmount: function() {
    return applyChain(this._willUnmount, this);
  }
};

//# sourceMappingURL=../../../map/src/Component/LifecycleMixin.map
