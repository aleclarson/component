var Component, ElementType, NativeComponent, NativeProps, ReactElement, assertType, assertTypes, configTypes, setChild, typeImpl;

ReactElement = require("ReactElement");

assertTypes = require("assertTypes");

assertType = require("assertType");

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
    type.propTypes = config.propTypes;
  }
  type.definePrototype({
    renderChild: ElementType(config.render)
  });
  type.defineValues(typeImpl.values);
  type.defineListeners(typeImpl.listeners);
  type.willReceiveProps(typeImpl.willReceiveProps);
  type.willUnmount(typeImpl.willUnmount);
  type.render(typeImpl.render);
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

typeImpl.render = function() {
  var props;
  props = this._nativeProps.values;
  props.ref = setChild.bind(this);
  return this.renderChild(props);
};

typeImpl.willReceiveProps = function(nextProps) {
  return this._nativeProps.attach(nextProps);
};

typeImpl.listeners = function() {
  return this._nativeProps.didSet((function(_this) {
    return function(newProps) {
      if (_this.child !== null) {
        return _this.child.setNativeProps(newProps);
      } else {
        return _this._queuedProps = newProps;
      }
    };
  })(this));
};

typeImpl.willUnmount = function() {
  return this._nativeProps.detach();
};

setChild = function(view) {
  this.child = view;
  if (view && this._queuedProps) {
    this.child.setNativeProps(this._queuedProps);
    this._queuedProps = null;
  }
};

//# sourceMappingURL=map/NativeComponent.map
