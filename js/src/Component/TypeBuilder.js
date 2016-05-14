var LazyCaller, Reaction, Type, assert, assertType, define, guard, isType, type;

LazyCaller = require("LazyCaller");

assertType = require("assertType");

Reaction = require("reaction");

isType = require("isType");

assert = require("assert");

define = require("define");

guard = require("guard");

Type = require("Type");

type = Type("ComponentTypeBuilder");

type.inherits(Type.Builder);

type.initInstance(function() {
  if (!isType(this, Type.Builder.Kind)) {
    global.failedInstance = this;
  }
  this.defineReactiveValues({
    view: null
  });
  return this.willBuild(function() {
    return this._buildRender();
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
    render = LazyCaller(loadComponent);
    this._loadComponent = loadComponent;
    this._render = function(props) {
      props.context = this;
      return render(props);
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
  },
  _buildRender: function() {
    var render;
    render = this._render;
    if (!render) {
      return;
    }
    return this.defineMethods({
      render: function(props) {
        if (!isType(props, Object)) {
          props = {};
        }
        return render.call(this, props);
      }
    });
  }
});

type.addMixins([require("./mixins/Styles")]);

module.exports = type.build();

//# sourceMappingURL=../../../map/src/Component/TypeBuilder.map
