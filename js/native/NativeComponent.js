var Component, ElementType, NativeComponent, NativeProps, ReactElement, assertType, assertTypes, configTypes, hook, typeImpl;

ReactElement = require("ReactElement");

assertTypes = require("assertTypes");

assertType = require("assertType");

hook = require("hook");

ElementType = require("../utils/ElementType");

NativeProps = require("./NativeProps");

Component = require("../Component");

configTypes = {
  render: Function,
  propTypes: Object.Maybe
};

module.exports = NativeComponent = function(name, config) {
  var type;
  assertType(name, String);
  assertTypes(config, configTypes);
  type = Component("Native" + name);
  if (config.propTypes) {
    type.defineProps(config.propTypes);
  }
  type.definePrototype({
    _renderChild: ElementType(config.render)
  });
  type.defineValues(typeImpl.values);
  type.defineBoundMethods(typeImpl.boundMethods);
  type.defineListeners(typeImpl.listeners);
  type.render(typeImpl.render);
  type.willReceiveProps(typeImpl.willReceiveProps);
  type.willUnmount(typeImpl.willUnmount);
  return type.build();
};

typeImpl = {};

typeImpl.values = {
  child: null,
  _queuedProps: null,
  _nativeProps: function() {
    return NativeProps(this.props, this.constructor.propTypes);
  }
};

typeImpl.boundMethods = {
  _hookRef: function(orig, view) {
    if (view && this._queuedProps) {
      view.setNativeProps(this._queuedProps);
      this._queuedProps = null;
    }
    this.child = view;
    orig(this);
  }
};

typeImpl.listeners = function() {
  return this._nativeProps.didSet((function(_this) {
    return function(newProps) {
      if (_this.child === null) {
        _this._queuedProps = newProps;
        return;
      }
      _this.child.setNativeProps(newProps);
    };
  })(this));
};

typeImpl.render = function() {
  var props;
  props = this._nativeProps.values;
  hook(props, "ref", this._hookRef);
  return this._renderChild(props);
};

typeImpl.willUnmount = function() {
  this._nativeProps.detach();
};

typeImpl.willReceiveProps = function(nextProps) {
  this._nativeProps.attach(nextProps);
};

//# sourceMappingURL=map/NativeComponent.map
