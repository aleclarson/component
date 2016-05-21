var Builder, Component, NamedFunction, Property, ReactCurrentOwner, ReactElement, Tracer, Type, assertType, build, createFactory, define, elementProps, hook, isType, setKind, setType;

require("isDev");

ReactCurrentOwner = require("ReactCurrentOwner");

NamedFunction = require("NamedFunction");

ReactElement = require("ReactElement");

assertType = require("assertType");

Property = require("Property");

setKind = require("setKind");

setType = require("setType");

Tracer = require("tracer");

isType = require("isType");

define = require("define");

Type = require("Type");

hook = require("hook");

Builder = require("./Builder");

module.exports = Component = NamedFunction("Component", function(name) {
  var self;
  self = Builder(name);
  hook(self, "build", build);
  return self;
});

setKind(Component, Function);

define(Component, {
  Type: {
    lazy: function() {
      return require("./Type");
    }
  },
  StyleMap: {
    lazy: function() {
      return require("./StyleMap");
    }
  }
});

build = function(orig) {
  var factory, type;
  type = orig.call(this);
  if (!isType(type, Function.Kind)) {
    throw Error("'type' must be defined!");
  }
  factory = createFactory(type);
  setType(factory, Component);
  factory.type = type;
  return factory;
};

createFactory = function(type) {
  return function(props) {
    var element, getValue, i, key, len, mixin, mixins, prop, ref, value;
    if (props.mixins) {
      mixins = steal(props, "mixins");
      assertType(mixins, Array, "props.mixins");
      ref = props.mixin;
      for (i = 0, len = ref.length; i < len; i++) {
        mixin = ref[i];
        for (key in mixin) {
          value = mixin[key];
          if (props[key] !== void 0) {
            continue;
          }
          props[key] = value;
        }
      }
    }
    key = null;
    if (props.key != null) {
      key = steal(props, "key");
      if (!isType(key, String)) {
        key = "" + key;
      }
    }
    element = {
      type: type,
      props: props,
      key: key
    };
    prop = Property({
      enumerable: false
    });
    for (key in elementProps) {
      getValue = elementProps[key];
      prop.define(element, key, getValue());
    }
    if (isDev) {
      prop.define(element, "_trace", Tracer("ReactElement()"));
    }
    return element;
  };
};

elementProps = {
  $$typeof: function() {
    return ReactElement.type;
  },
  _owner: function() {
    return ReactCurrentOwner.current;
  },
  _store: function() {
    return {
      validated: false
    };
  }
};

//# sourceMappingURL=../../../map/src/Component/index.map
