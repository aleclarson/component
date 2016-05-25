var ElementType, Kind, NamedFunction, Property, ReactCurrentOwner, ReactElement, Tracer, Void, applyMixins, assertType, define, defineHiddenProperties, emptyFunction, hidden, hiddenProperties, isType, setKind, setType, steal, stealKey;

require("isDev");

ReactCurrentOwner = require("ReactCurrentOwner");

NamedFunction = require("NamedFunction");

emptyFunction = require("emptyFunction");

ReactElement = require("ReactElement");

assertType = require("assertType");

Property = require("Property");

setType = require("setType");

setKind = require("setKind");

Tracer = require("tracer");

isType = require("isType");

define = require("define");

steal = require("steal");

Kind = require("Kind");

Void = require("Void");

hidden = Property({
  enumerable: false
});

module.exports = ElementType = NamedFunction("ElementType", function(componentType, initProps) {
  var self;
  assertType(componentType, Kind(Function));
  assertType(initProps, [Function, Void]);
  if (!initProps) {
    initProps = emptyFunction.thatReturnsArgument;
  }
  self = function(props) {
    var element, key;
    if (!props) {
      props = {};
    }
    assertType(props, Object, "props");
    applyMixins(props);
    key = stealKey(props);
    element = {};
    defineHiddenProperties(element);
    if (key !== null) {
      element.key = key;
    }
    element.type = componentType;
    element.props = initProps(props);
    return element;
  };
  self.componentType = componentType;
  return setType(self, ElementType);
});

setKind(ElementType, Function);

define(ElementType.prototype, {
  propTypes: {
    get: function() {
      return this.componentType.propTypes;
    }
  }
});

applyMixins = function(props) {
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

stealKey = function(props) {
  var key;
  key = steal(props, "key", null);
  if (key === null) {
    return key;
  }
  if (isType(key, String)) {
    return key;
  }
  return key + "";
};

hiddenProperties = {
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

defineHiddenProperties = function(element) {
  var getValue, key;
  for (key in hiddenProperties) {
    getValue = hiddenProperties[key];
    hidden.define(element, key, getValue());
  }
  if (!isDev) {
    return;
  }
  return hidden.define(element, "_trace", Tracer("ReactElement()"));
};

//# sourceMappingURL=../../../map/src/Component/ElementType.map
