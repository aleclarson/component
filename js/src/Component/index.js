var Component, ReactComponent, Type, type;

ReactComponent = require("../mocks/ReactComponent");

Type = require("type");

type = Type("Component");

type.inherits(ReactComponent);

type.returnExisting(function() {
  return Component.Builder();
});

type.defineProperties({
  view: {
    get: function() {
      return this.context.view || this;
    }
  },
  context: {
    get: function() {
      return this.props.context || this;
    }
  }
});

type.defineStatics({
  Builder: {
    lazy: function() {
      return require("./Builder");
    }
  },
  Type: {
    lazy: function() {
      return require("./Type");
    }
  },
  traverseParents: function(component) {
    var owner, results;
    results = [];
    while (true) {
      results.push(component);
      owner = component._reactInternalInstance._currentElement._owner;
      if (!owner) {
        break;
      }
      component = owner._instance;
    }
    return results;
  }
});

type.initInstance(function() {
  return this.context.view = this;
});

type.defineMethods({
  componentDidMount: function() {},
  componentDidUnmount: function() {}
});

module.exports = Component = type.build();

//# sourceMappingURL=../../../map/src/Component/index.map
