var LazyVar, NamedFunction, Type, modx_Type, modx_TypeBuilder, setKind, setType;

NamedFunction = require("NamedFunction");

LazyVar = require("LazyVar");

setKind = require("setKind");

setType = require("setType");

Type = require("Type");

modx_TypeBuilder = LazyVar(function() {
  return require("./TypeBuilder");
});

modx_Type = NamedFunction("modx_Type", function(name) {
  var self;
  self = modx_TypeBuilder.call(name);
  self.didBuild(function(type) {
    return setType(type, modx_Type);
  });
  return self;
});

module.exports = setKind(modx_Type, Type);

//# sourceMappingURL=map/Type.map
