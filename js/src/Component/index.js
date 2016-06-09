var Component, ComponentBuilder, ElementType, NamedFunction, ReactComponent, assertType, build, define, hook, setKind;

require("isDev");

ReactComponent = require("ReactComponent");

NamedFunction = require("NamedFunction");

assertType = require("assertType");

setKind = require("setKind");

define = require("define");

hook = require("hook");

ComponentBuilder = require("./Builder");

ElementType = require("./ElementType");

module.exports = Component = NamedFunction("Component", function(name) {
  var self;
  self = ComponentBuilder(name);
  hook(self, "build", build);
  return self;
});

setKind(Component, ReactComponent);

build = function(build) {
  var componentType, elementType;
  componentType = build.call(this);
  elementType = ElementType(componentType);
  elementType.componentType = componentType;
  return elementType;
};

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

//# sourceMappingURL=../../../map/src/Component/index.map
