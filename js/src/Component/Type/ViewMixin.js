var Component, assertType, instImpl, sync, typeImpl, viewImpl;

assertType = require("assertType");

sync = require("sync");

Component = require("..");

module.exports = function(type) {
  type.defineValues(typeImpl.values);
  type.definePrototype(typeImpl.prototype);
  type.defineMethods(typeImpl.methods);
  return type.initInstance(typeImpl.initInstance);
};

typeImpl = {};

typeImpl.values = {
  _viewType: function() {
    return Component();
  }
};

typeImpl.prototype = {
  propTypes: {
    get: function() {
      return this._viewType.propTypes;
    },
    set: function(propTypes) {
      return this._viewType.propTypes = propTypes;
    }
  },
  propDefaults: {
    get: function() {
      return this._viewType.propDefaults;
    },
    set: function(propDefaults) {
      return this._viewType.propDefaults = propDefaults;
    }
  }
};

typeImpl.methods = {};

["willMount", "didMount", "willUnmount", "shouldUpdate", "render", "isRenderPrevented"].forEach(function(key) {
  return typeImpl.methods[key] = function(func) {
    this._viewType[key](function() {
      return func.apply(this._instance, arguments);
    });
  };
});

typeImpl.initInstance = function() {
  var type;
  this._willBuild.push(instImpl.willBuild);
  type = this._viewType;
  type.definePrototype(viewImpl.prototype);
  type.initInstance(viewImpl.initInstance);
  return type.willBuild(viewImpl.willBuild);
};

instImpl = {};

instImpl.values = {
  _view: null
};

instImpl.prototype = {
  view: {
    get: function() {
      return this._view;
    }
  },
  props: {
    get: function() {
      return this._view.props;
    }
  },
  render: function(props) {
    if (!props) {
      props = {};
    }
    props._instance = this;
    return this.constructor.View(props);
  }
};

instImpl.willBuild = function() {
  this.defineStatics({
    View: this._viewType.build()
  });
  if (this._kind) {
    return;
  }
  this.defineValues(instImpl.values);
  return this.definePrototype(instImpl.prototype);
};

viewImpl = {};

viewImpl.prototype = {
  _instance: {
    get: function() {
      return this.props._instance;
    }
  }
};

viewImpl.initInstance = function() {
  return this._instance._view = this;
};

viewImpl.willBuild = function() {
  return this._willUnmount.push(function() {
    return this._instance._view = null;
  });
};

//# sourceMappingURL=../../../../map/src/Component/Type/ViewMixin.map
