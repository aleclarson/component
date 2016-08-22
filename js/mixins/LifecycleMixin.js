var Builder, ReactComponent, applyChain, assertType, emptyFunction, inheritArray, inheritArrays, instImpl, mutable, typeImpl;

mutable = require("Property").mutable;

ReactComponent = require("ReactComponent");

emptyFunction = require("emptyFunction");

assertType = require("assertType");

applyChain = require("applyChain");

Builder = require("Builder");

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
  _willUpdate: function() {
    return [];
  },
  _didUpdate: function() {
    return [];
  },
  _willUnmount: function() {
    return [];
  }
};

typeImpl.methods = {
  render: function(func) {
    assertType(func, Function);
    mutable.define(this, "_render", {
      value: func
    });
  },
  shouldUpdate: function(func) {
    assertType(func, Function);
    mutable.define(this, "_shouldUpdate", {
      value: func
    });
  },
  willReceiveProps: function(func) {
    assertType(func, Function);
    mutable.define(this, "_willReceiveProps", {
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
  willUpdate: function(func) {
    assertType(func, Function);
    this._willUpdate.push(func);
  },
  didUpdate: function(func) {
    assertType(func, Function);
    this._didUpdate.push(func);
  },
  willUnmount: function(func) {
    assertType(func, Function);
    this._willUnmount.push(func);
  }
};

typeImpl.initInstance = function() {
  return this.willBuild(instImpl.willBuild);
};

instImpl = {};

instImpl.willBuild = function() {
  var kind, ownMethods;
  kind = this._kind;
  ownMethods = {};
  if (kind === false) {
    this.defineMethods(instImpl.methods);
    ownMethods.__render = this._render || emptyFunction.thatReturnsFalse;
    ownMethods.__shouldUpdate = this._shouldUpdate || emptyFunction.thatReturnsTrue;
    ownMethods.__willReceiveProps = this._willReceiveProps || emptyFunction;
    this._delegate.defineMethods(ownMethods);
  } else {
    this._render && (ownMethods.__render = this._render);
    this._shouldUpdate && (ownMethods.__shouldUpdate = this._shouldUpdate);
    this._willReceiveProps && (ownMethods.__willReceiveProps = this._willReceiveProps);
    this._delegate.overrideMethods(ownMethods);
    inheritArrays(this, (function() {
      var prototype;
      prototype = kind.prototype;
      return {
        _willMount: prototype.__willMount,
        _didMount: prototype.__didMount,
        _willUpdate: prototype.__willUpdate,
        _didUpdate: prototype.__didUpdate,
        _willUnmount: prototype.__willUnmount
      };
    })());
  }
  return this.definePrototype({
    __willMount: this._willMount,
    __didMount: this._didMount,
    __willUpdate: this._willUpdate,
    __didUpdate: this._didUpdate,
    __willUnmount: this._willUnmount
  });
};

instImpl.methods = {
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
  componentWillUpdate: function() {
    return applyChain(this.__willUpdate, this._delegate);
  },
  componentDidUpdate: function() {
    return applyChain(this.__didUpdate, this._delegate);
  },
  componentWillUnmount: function() {
    return applyChain(this.__willUnmount, this._delegate);
  }
};

inheritArrays = function(obj, arrayMap) {
  var array, key;
  for (key in arrayMap) {
    array = arrayMap[key];
    if (Array.isArray(array)) {
      inheritArray(obj, key, array);
    }
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
