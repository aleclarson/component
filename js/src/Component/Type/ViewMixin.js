var ComponentBuilder, ElementType, Property, frozen, instImpl, typeImpl, viewImpl;

require("isDev");

Property = require("Property");

ComponentBuilder = require("../Builder");

ElementType = require("../ElementType");

frozen = Property({
  frozen: true
});

module.exports = function(type) {
  type.defineValues(typeImpl.values);
  type.definePrototype(typeImpl.prototype);
  return type.initInstance(typeImpl.initInstance);
};

typeImpl = {};

typeImpl.values = {
  _componentType: function() {
    var name, self;
    name = this._name ? this._name + "_View" : null;
    self = ComponentBuilder(name);
    frozen.define(self, "_delegate", this);
    return self;
  }
};

typeImpl.prototype = {};

["propTypes", "propDefaults"].forEach(function(key) {
  return typeImpl.prototype[key] = {
    get: function() {
      return this._componentType[key];
    },
    set: function(newValue) {
      return this._componentType[key] = newValue;
    }
  };
});

[].forEach(function(key) {});

["render", "shouldUpdate", "defineListeners", "isRenderPrevented"].forEach(function(key) {
  return typeImpl.prototype[key] = {
    value: function(func) {
      var bound;
      bound = function() {
        return func.apply(this._delegate, arguments);
      };
      if (isDev) {
        bound.toString = function() {
          return func.toString();
        };
      }
      return this._componentType[key](bound);
    }
  };
});

["willMount", "didMount", "willUnmount", "defineStyles", "overrideStyles", "defineNativeValues", "defineReactions"].forEach(function(key) {
  return typeImpl.prototype[key] = {
    value: function(func) {
      return this._componentType[key](func);
    }
  };
});

["_willMount", "_didMount", "_willUnmount"].forEach(function(key) {
  return typeImpl.prototype[key] = {
    get: function() {
      return this._componentType[key];
    }
  };
});

typeImpl.initInstance = function() {
  this._willBuild.push(instImpl.willBuild);
  return this._componentType.willBuild(viewImpl.willBuild);
};

instImpl = {};

instImpl.prototype = {
  props: {
    get: function() {
      return this._view.props;
    }
  },
  view: {
    get: function() {
      return this._view;
    }
  }
};

instImpl.values = {
  render: function() {
    return ElementType(this.constructor.View, (function(_this) {
      return function(props) {
        props._delegate = _this;
        return props;
      };
    })(this));
  },
  _view: null
};

instImpl.willBuild = function() {
  this.defineStatics({
    View: this._componentType.build()
  });
  if (this._kind instanceof Component.Type) {
    return;
  }
  this.defineValues(instImpl.values);
  return this.definePrototype(instImpl.prototype);
};

viewImpl = {};

viewImpl.prototype = {
  _delegate: {
    get: function() {
      return this.props._delegate;
    }
  }
};

viewImpl.willBuild = function() {
  if (this._kind instanceof Component.Type) {
    return;
  }
  this.definePrototype(viewImpl.prototype);
  return this._willBuild.push(function() {
    this._initInstance.unshift(viewImpl.initInstance);
    return this._willUnmount.push(viewImpl.willUnmount);
  });
};

viewImpl.initInstance = function() {
  return this._delegate._view = this;
};

viewImpl.willUnmount = function() {
  return this._delegate._view = null;
};

//# sourceMappingURL=../../../../map/src/Component/Type/ViewMixin.map
