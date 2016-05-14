var ComponentType, NamedFunction, Type, TypeBuilder, setKind, setType;

NamedFunction = require("NamedFunction");

setKind = require("setKind");

setType = require("setType");

Type = require("Type");

TypeBuilder = require("./TypeBuilder");

module.exports = ComponentType = NamedFunction("ComponentType", function(name) {
  var self;
  self = TypeBuilder(name);
  self.didBuild(function(type) {
    return setType(type, ComponentType);
  });
  return self;
});

setKind(ComponentType, Type);

//# sourceMappingURL=../../../map/src/Component/Type.map
