var Builder, ReactComponent, applyChain, assert, assertType, emptyFunction, guard, inheritArray, instImpl, sync, typeImpl, viewImpl;

require("isDev");

ReactComponent = require("ReactComponent");

emptyFunction = require("emptyFunction");

assertType = require("assertType");

applyChain = require("applyChain");

Builder = require("Builder");

assert = require("assert");

guard = require("guard");

sync = require("sync");

module.exports = function(type) {
  type.defineValues(typeImpl.values);
  type.defineMethods(typeImpl.methods);
  return type.initInstance(typeImpl.initInstance);
};

typeImpl = {};

typeImpl.values = {
  _render: null,
  _shouldUpdate: null,
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

typeImpl.methods = {
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

typeImpl.initInstance = function() {
  return this._willBuild.push(instImpl.willBuild);
};

instImpl = {};

instImpl.willBuild = function() {
  var kind, ownMethods;
  kind = this._kind;
  ownMethods = {};
  if (kind === ReactComponent) {
    this.defineMethods(viewImpl.methods);
    ownMethods.render = this._render || emptyFunction.thatReturnsFalse;
    ownMethods.shouldComponentUpdate = this._shouldUpdate || emptyFunction.thatReturnsTrue;
  } else {
    inheritArray(this, "_willMount", kind);
    inheritArray(this, "_didMount", kind);
    inheritArray(this, "_willUnmount", kind);
    if (this._render) {
      ownMethods.render = this._render;
    }
    if (this._shouldUpdate) {
      ownMethods.shouldComponentUpdate = this._shouldUpdate;
    }
  }
  this.defineMethods(ownMethods);
  return this.definePrototype({
    _willMount: this._willMount,
    _didMount: this._didMount,
    _willUnmount: this._willUnmount
  });
};

viewImpl = {};

viewImpl.methods = {
  componentWillMount: function() {
    return applyChain(this._willMount, this._delegate);
  },
  componentDidMount: function() {
    return applyChain(this._didMount, this._delegate);
  },
  componentWillUnmount: function() {
    return applyChain(this._willUnmount, this._delegate);
  }
};

inheritArray = function(obj, key, type) {
  var inherited;
  inherited = type.prototype[key];
  assertType(inherited, Array);
  if (obj[key].length) {
    if (!inherited.length) {
      return;
    }
    obj[key] = inherited.concat(obj[key]);
  } else {
    obj[key] = inherited;
  }
};

//# sourceMappingURL=../../../map/src/Component/LifecycleMixin.map
