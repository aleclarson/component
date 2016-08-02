var Component, ComponentBuilder, ElementType, Type, fromArgs, frozen, instImpl, isType, mergeDefaults, modx_Type, steal, sync, type, viewImpl;

frozen = require("Property").frozen;

mergeDefaults = require("mergeDefaults");

fromArgs = require("fromArgs");

isType = require("isType");

steal = require("steal");

sync = require("sync");

Type = require("Type");

modx_Type = require("./Type");

Component = require("../Component");

ElementType = require("../utils/ElementType");

ComponentBuilder = require("../ComponentBuilder");

type = Type("modx_TypeBuilder");

type.inherits(Type.Builder);

type.trace();

type.defineValues({
  _componentType: function() {
    var name;
    name = this._name ? this._name + "_View" : null;
    type = ComponentBuilder(name);
    frozen.define(type, "_delegate", {
      value: this
    });
    return type;
  }
});

type.overrideMethods({
  inherits: function(kind) {
    this.__super(arguments);
    if (kind instanceof modx_Type) {
      this._componentType.inherits(kind.View);
    }
  }
});

type.willBuild(function() {
  var keys;
  keys = {
    "propTypes": "propTypes",
    "propDefaults": "propDefaults"
  };
  this.definePrototype(sync.map(keys, function(key) {
    return {
      get: function() {
        return this._componentType[key];
      },
      set: function(newValue) {
        return this._componentType[key] = newValue;
      }
    };
  }));
  keys = {
    "render": "render",
    "isRenderPrevented": "isRenderPrevented",
    "shouldUpdate": "shouldUpdate",
    "willReceiveProps": "willReceiveProps",
    "willMount": "willMount",
    "didMount": "didMount",
    "willUnmount": "willUnmount",
    "defineNativeValues": "defineNativeValues",
    "defineListeners": "defineListeners",
    "defineReactions": "defineReactions",
    "defineStyles": "defineStyles",
    "appendStyles": "appendStyles",
    "overrideStyles": "overrideStyles"
  };
  this.definePrototype(sync.map(keys, function(key) {
    return {
      value: function(func) {
        return this._componentType[key](func);
      }
    };
  }));
  keys = {
    "_willMount": "_willMount",
    "_didMount": "_didMount",
    "_willUnmount": "_willUnmount"
  };
  return this.definePrototype(sync.map(keys, function(key) {
    return {
      get: function() {
        return this._componentType[key];
      }
    };
  }));
});

type.initInstance(function() {
  this._willBuild.push(instImpl.willBuild);
  return this._componentType.willBuild(viewImpl.willBuild);
});

module.exports = type.build();

instImpl = {};

instImpl.willBuild = function() {
  var View;
  View = this._componentType.build();
  this.defineStatics({
    View: View
  });
  if (!(this._kind instanceof modx_Type)) {
    this.defineValues(instImpl.values);
    return this.defineGetters(instImpl.getters);
  }
};

instImpl.values = {
  render: function() {
    var styles, transform;
    styles = this._styles;
    transform = styles && steal(styles, "transform");
    return ElementType(this.constructor.View, (function(_this) {
      return function(props) {
        if (styles) {
          if (isType(props.styles, Object)) {
            mergeDefaults(props.styles, styles);
            if (Array.isArray(transform)) {
              if (Array.isArray(props.styles.transform)) {
                props.styles.transform.concat(transform);
              } else {
                props.style.transform = transform;
              }
            }
          } else {
            mergeDefaults(props.styles = {}, styles);
            props.styles.transform = transform;
          }
        }
        props.delegate = _this;
        return _this._props = props;
      };
    })(this));
  },
  _props: null,
  _view: null,
  _styles: fromArgs("styles")
};

instImpl.getters = {
  props: function() {
    return this._props;
  },
  view: function() {
    return this._view;
  }
};

viewImpl = {};

viewImpl.willBuild = function() {
  if (!(this._kind instanceof modx_Type)) {
    return this._willBuild.push(function() {
      this._initInstance.unshift(viewImpl.initInstance);
      return this._willUnmount.push(viewImpl.willUnmount);
    });
  }
};

viewImpl.initInstance = function() {
  return this.props.delegate._view = this;
};

viewImpl.willUnmount = function() {
  var delegate;
  delegate = this.props.delegate;
  delegate._props = null;
  return delegate._view = null;
};

//# sourceMappingURL=map/TypeBuilder.map
