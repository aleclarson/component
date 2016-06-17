var ElementType, Kind, NamedFunction, ReactCurrentOwner, ReactElement, Tracer, Void, applyMixinsToProps, assertType, define, emptyFunction, hidden, isType, setKind, setType, steal, stealKeyFromProps, wrapValue;

require("isDev");

hidden = require("Property").hidden;

ReactCurrentOwner = require("ReactCurrentOwner");

NamedFunction = require("NamedFunction");

emptyFunction = require("emptyFunction");

ReactElement = require("ReactElement");

assertType = require("assertType");

wrapValue = require("wrapValue");

setType = require("setType");

setKind = require("setKind");

Tracer = require("tracer");

isType = require("isType");

define = require("define");

steal = require("steal");

Kind = require("Kind");

Void = require("Void");

module.exports = ElementType = NamedFunction("ElementType", function(componentType, initProps) {
  var self;
  assertType(componentType, Kind(Function));
  assertType(initProps, [Function, Void]);
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
    hidden.define(element, "$$typeof", ReactElement.type);
    hidden.define(element, "_owner", ReactCurrentOwner.current);
    hidden.define(element, "_store", {
      validated: false
    });
    hidden.define(element, "_trace", Tracer("ReactElement()"));
    return element;
  };
  self.componentType = componentType;
  return setType(self, ElementType);
});

setKind(ElementType, Function);

define(ElementType.prototype, "propTypes", {
  get: function() {
    return this.componentType.propTypes;
  }
});

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

//# sourceMappingURL=../../../map/src/Component/ElementType.map
