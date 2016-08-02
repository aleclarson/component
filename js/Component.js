var ElementType, NamedFunction, ReactComponent, assertType, build, define, hook, modx_Component, modx_ComponentBuilder, setKind;

require("isDev");

ReactComponent = require("ReactComponent");

NamedFunction = require("NamedFunction");

assertType = require("assertType");

setKind = require("setKind");

define = require("define");

hook = require("hook");

modx_ComponentBuilder = require("./ComponentBuilder");

ElementType = require("./utils/ElementType");

modx_Component = NamedFunction("modx_Component", function(name) {
  var self;
  self = modx_ComponentBuilder(name);
  hook(self, "build", build);
  return self;
});

module.exports = setKind(modx_Component, ReactComponent);

build = function(build) {
  var componentType, elementType;
  componentType = build.call(this);
  elementType = ElementType(componentType);
  elementType.componentType = componentType;
  return elementType;
};

//# sourceMappingURL=map/Component.map
