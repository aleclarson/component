var ComponentType, ComponentTypeBuilder, NamedFunction, Type, setKind, setType;

NamedFunction = require("NamedFunction");

setKind = require("setKind");

setType = require("setType");

Type = require("Type");

ComponentTypeBuilder = require("./Builder");

module.exports = ComponentType = NamedFunction("ComponentType", function(name) {
  var self;
  self = ComponentTypeBuilder(name);
  self.didBuild(function(type) {
    Type.augment(type);
    return setType(type, ComponentType);
  });
  return self;
});

setKind(ComponentType, Type);

//# sourceMappingURL=../../../../map/src/Component/Type/index.map
