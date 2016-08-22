var Component, ComponentBuilder, ElementType, Type, frozen, instImpl, modx_Type, sync, type, viewImpl;

frozen = require("Property").frozen;

Type = require("Type");

sync = require("sync");

modx_Type = require("./Type");

Component = require("./Component");

ElementType = require("./utils/ElementType");

ComponentBuilder = require("./ComponentBuilder");

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
    "defineProps": "defineProps",
    "render": "render",
    "isRenderPrevented": "isRenderPrevented",
    "shouldUpdate": "shouldUpdate",
    "willReceiveProps": "willReceiveProps",
    "willMount": "willMount",
    "didMount": "didMount",
    "willUnmount": "willUnmount",
    "willUpdate": "willUpdate",
    "didUpdate": "didUpdate",
    "defineNativeValues": "defineNativeValues",
    "defineListeners": "defineListeners",
    "defineReactions": "defineReactions",
    "defineStyles": "defineStyles",
    "appendStyles": "appendStyles",
    "overrideStyles": "overrideStyles"
  };
  this.definePrototype(sync.map(keys, function(key) {
    return {
      value: function(arg) {
        return this._componentType[key](arg);
      }
    };
  }));
  keys = {
    "_willMount": "_willMount",
    "_didMount": "_didMount",
    "_willUnmount": "_willUnmount",
    "_willUpdate": "_willUpdate",
    "_didUpdate": "_didUpdate"
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
  this.willBuild(instImpl.willBuild);
  return this._componentType.willBuild(viewImpl.willBuild);
});

module.exports = type.build();

instImpl = {
  willBuild: function() {
    var View;
    View = this._componentType.build();
    this.defineStatics({
      View: View
    });
    if (!(this._kind instanceof modx_Type)) {
      this.defineValues(instImpl.defineValues);
      return this.defineGetters(instImpl.defineGetters);
    }
  },
  defineValues: {
    render: function() {
      return ElementType(this.constructor.View, (function(_this) {
        return function(props) {
          props.delegate = _this;
          return props;
        };
      })(this));
    },
    _props: null,
    _view: null
  },
  defineGetters: {
    props: function() {
      return this._props;
    },
    view: function() {
      return this._view;
    }
  }
};

viewImpl = {
  willBuild: function() {
    if (!(this._kind instanceof modx_Type)) {
      return this.willBuild(function() {
        this._initPhases.unshift(viewImpl.initInstance);
        this._willUnmount.push(viewImpl.willUnmount);
        return this.defineGetters(viewImpl.defineGetters);
      });
    }
  },
  defineGetters: {
    _delegate: function() {
      return this.props.delegate;
    }
  },
  initInstance: function() {
    return this._delegate._view = this;
  },
  willUnmount: function() {
    this._props = null;
    return this._view = null;
  }
};

//# sourceMappingURL=map/TypeBuilder.map
