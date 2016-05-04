var ComponentType, NamedFunction, TypeBuilder;

NamedFunction = require("NamedFunction");

TypeBuilder = require("./TypeBuilder");

module.exports = ComponentType = NamedFunction("ComponentType", function() {
  var self;
  self = TypeBuilder();
  self.didBuild(function(type) {
    return setType(type, ComponentType);
  });
  return self;
});

//# sourceMappingURL=../../../map/src/Component/Type.map
