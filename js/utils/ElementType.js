var ElementType, NamedFunction, ReactCurrentOwner, ReactElement, Tracer, applyMixinsToProps, assertType, define, emptyFunction, hidden, isType, setInternals, setKind, setType, steal, stealKeyFromProps;

require("isDev");

hidden = require("Property").hidden;

ReactCurrentOwner = require("ReactCurrentOwner");

NamedFunction = require("NamedFunction");

emptyFunction = require("emptyFunction");

ReactElement = require("ReactElement");

assertType = require("assertType");

setType = require("setType");

setKind = require("setKind");

Tracer = require("tracer");

isType = require("isType");

define = require("define");

steal = require("steal");

ElementType = NamedFunction("ElementType", function(componentType, initProps) {
  var self;
  assertType(componentType, Function.Kind);
  assertType(initProps, Function.Maybe);
  if (!initProps) {
    initProps = emptyFunction.thatReturnsArgument;
  }
  self = function(props, children) {
    var element, elementKey;
    if (!props) {
      props = {};
    }
    assertType(props, Object, "props");
    if (children) {
      props.children = children;
    }
    elementKey = stealKeyFromProps(props);
    applyMixinsToProps(props);
    element = {
      key: elementKey,
      type: componentType,
      props: initProps(props)
    };
    setInternals(element, {
      $$typeof: ReactElement.type,
      _owner: ReactCurrentOwner.current,
      _store: {
        validated: false
      },
      _trace: isDev && Tracer("ReactElement()")
    });
    return element;
  };
  self.componentType = componentType;
  return setType(self, ElementType);
});

module.exports = setKind(ElementType, Function);

define(ElementType.prototype, "propTypes", {
  get: function() {
    return this.componentType.propTypes;
  }
});

setInternals = function(obj, values) {
  var config, key, value;
  config = {};
  for (key in values) {
    value = values[key];
    config.value = value;
    hidden.define(obj, key, config);
  }
};

applyMixinsToProps = function(props) {
  var i, key, len, mixin, mixins, value;
  if (!props.mixins) {
    return;
  }
  mixins = steal(props, "mixins");
  assertType(mixins, Array, "props.mixins");
  for (i = 0, len = mixins.length; i < len; i++) {
    mixin = mixins[i];
    for (key in mixin) {
      value = mixin[key];
      if (props[key] !== void 0) {
        continue;
      }
      props[key] = value;
    }
  }
};

stealKeyFromProps = function(props) {
  var key;
  key = steal(props, "key");
  if (key === void 0) {
    return;
  }
  if (isType(key, String)) {
    return key;
  }
  return key + "";
};

//# sourceMappingURL=map/ElementType.map
