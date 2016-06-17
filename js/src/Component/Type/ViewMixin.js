var $, ComponentBuilder, ElementType, Property, frozen, instImpl, mergeStyles, mutable, typeImpl, viewImpl;

Property = require("Property");

ComponentBuilder = require("../Builder");

ElementType = require("../ElementType");

mutable = Property.mutable, frozen = Property.frozen;

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

["render", "shouldUpdate", "isRenderPrevented", "willMount", "didMount", "willUnmount", "defineStyles", "overrideStyles", "defineNativeValues", "defineListeners", "defineReactions"].forEach(function(key) {
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

$ = {
  delegate: Symbol("Component.delegate"),
  styles: Symbol("Component.styles"),
  props: Symbol("Component.props"),
  view: Symbol("Component.view")
};

instImpl = {};

instImpl.willBuild = function() {
  this.defineStatics({
    View: this._componentType.build()
  });
  if (!(this._kind instanceof Component.Type)) {
    this.definePrototype(instImpl.prototype);
    this.defineValues(instImpl.values);
    return this.initInstance(instImpl.initInstance);
  }
};

instImpl.prototype = {
  props: {
    get: function() {
      return this[$.props];
    }
  },
  view: {
    get: function() {
      return this[$.view];
    }
  }
};

instImpl.values = {
  render: function() {
    return ElementType(this.constructor.View, (function(_this) {
      return function(props) {
        props[$.delegate] = _this;
        mergeStyles(props, _this[$.styles]);
        return _this[$.props] = props;
      };
    })(this));
  }
};

instImpl.initInstance = function(options) {
  if (options == null) {
    options = {};
  }
  mutable.define(this, $.props, null);
  mutable.define(this, $.view, null);
  return mutable.define(this, $.styles, options.styles || null);
};

mergeStyles = function(props, styles) {
  if (!styles) {
    return;
  }
  if (props.styles) {
    combine(props.styles, styles);
    return;
  }
  props.styles = styles;
};

viewImpl = {};

viewImpl.prototype = {
  _delegate: {
    get: function() {
      return this.props[$.delegate];
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
  return this._delegate[$.view] = this;
};

viewImpl.willUnmount = function() {
  var delegate;
  delegate = this._delegate;
  delegate[$.props] = null;
  return delegate[$.view] = null;
};

//# sourceMappingURL=../../../../map/src/Component/Type/ViewMixin.map
