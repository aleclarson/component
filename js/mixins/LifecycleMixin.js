var Builder, ReactComponent, applyChain, assert, assertType, emptyFunction, frozen, inheritArray, instImpl, sync, typeImpl, viewImpl;

require("isDev");

frozen = require("Property").frozen;

ReactComponent = require("ReactComponent");

emptyFunction = require("emptyFunction");

assertType = require("assertType");

applyChain = require("applyChain");

Builder = require("Builder");

assert = require("assert");

sync = require("sync");

module.exports = function(type) {
  type.defineValues(typeImpl.values);
  type.defineMethods(typeImpl.methods);
  return type.initInstance(typeImpl.initInstance);
};

typeImpl = {};

typeImpl.values = {
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
  render: function(func) {
    assertType(func, Function);
    frozen.define(this, "_render", {
      value: func
    });
  },
  shouldUpdate: function(func) {
    assertType(func, Function);
    frozen.define(this, "_shouldUpdate", {
      value: func
    });
  },
  willReceiveProps: function(func) {
    assertType(func, Function);
    frozen.define(this, "_willReceiveProps", {
      value: func
    });
  },
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
    ownMethods.__render = this._render || emptyFunction.thatReturnsFalse;
    ownMethods.__shouldUpdate = this._shouldUpdate || emptyFunction.thatReturnsTrue;
    ownMethods.__willReceiveProps = this._willReceiveProps || emptyFunction;
    this._delegate.defineMethods(ownMethods);
  } else {
    inheritArray(this, "_willMount", kind.prototype.__willMount);
    inheritArray(this, "_didMount", kind.prototype.__didMount);
    inheritArray(this, "_willUnmount", kind.prototype.__willUnmount);
    if (this._render) {
      ownMethods.__render = this._render;
    }
    if (this._shouldUpdate) {
      ownMethods.__shouldUpdate = this._shouldUpdate;
    }
    if (this._willReceiveProps) {
      ownMethods.__willReceiveProps = this._willReceiveProps;
    }
    this._delegate.overrideMethods(ownMethods);
  }
  return this.definePrototype({
    __willMount: this._willMount,
    __didMount: this._didMount,
    __willUnmount: this._willUnmount
  });
};

viewImpl = {};

viewImpl.methods = {
  render: function() {
    return this._delegate.__render();
  },
  shouldComponentUpdate: function(nextProps) {
    return this._delegate.__shouldUpdate(nextProps);
  },
  componentWillReceiveProps: function(nextProps) {
    return this._delegate.__willReceiveProps(nextProps);
  },
  componentWillMount: function() {
    return applyChain(this.__willMount, this._delegate);
  },
  componentDidMount: function() {
    return applyChain(this.__didMount, this._delegate);
  },
  componentWillUnmount: function() {
    return applyChain(this.__willUnmount, this._delegate);
  }
};

inheritArray = function(obj, key, inherited) {
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

//# sourceMappingURL=map/LifecycleMixin.map
