var LazyVar, Reaction, Type, assert, assertType, define, ref, type;

ref = require("type-utils"), assert = ref.assert, assertType = ref.assertType;

Reaction = require("reaction");

LazyVar = require("lazy-var");

define = require("define");

Type = require("Type");

type = Type("ComponentType_Builder");

type.inherits(Type.Builder);

type.initInstance(function() {
  this.defineReactiveValues({
    view: null
  });
  return this.willBuild(function() {
    assert(this._render, "Must call 'loadComponent' or 'render' before building!");
    return this.defineMethods({
      render: this._render
    });
  });
});

type.defineValues({
  _loadComponent: null,
  _render: null,
  _styles: null,
  _hasNativeValues: false,
  _hasListeners: false,
  _hasReactions: false
});

type.defineMethods({
  loadComponent: function(loadComponent) {
    var render;
    assertType(loadComponent, Function);
    assert(!this._loadComponent, "'loadComponent' is already defined!");
    assert(!this._render, "'render' is already defined!");
    render = LazyVar(function() {
      return loadComponent();
    });
    this._loadComponent = loadComponent;
    this._render = function(props) {
      if (!props) {
        props = {};
      }
      props.context = this;
      return render.get()(props);
    };
  },
  render: function(render) {
    assertType(render, Function);
    assert(!this._render, "'render' is already defined!");
    this._render = render;
  },
  defineNativeValues: function(createNativeValues) {
    assertType(createNativeValues, Function);
    throw Error("Not yet implemented!");
  },
  defineListeners: function(createListeners) {
    assertType(createListeners, Function);
    throw Error("Not yet implemented!");
  },
  defineReactions: function(reactions) {
    throw Error("Not yet implemented!");
  },
  _startReactions: function() {
    throw Error("Not yet implemented!");
  },
  _stopReactions: function() {
    throw Error("Not yet implemented!");
  }
});

type.addMixins([require("./mixins/Styles")]);

module.exports = type.build();

//# sourceMappingURL=../../../map/src/Component/TypeBuilder.map
