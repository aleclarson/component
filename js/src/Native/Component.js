var Component, NativeComponent, NativeProps, ReactElement, assertType, assertTypes, configTypes, onRef, throwFailure, typeImpl;

throwFailure = require("failure").throwFailure;

ReactElement = require("ReactElement");

assertTypes = require("assertTypes");

assertType = require("assertType");

NativeProps = require("./Props");

Component = require("../Component");

configTypes = {
  render: Function,
  propTypes: Object
};

module.exports = NativeComponent = function(name, config) {
  var type;
  assertType(name, String);
  assertTypes(config, configTypes);
  type = Component("Native" + name);
  type.definePrototype({
    _propTypes: {
      value: config.propTypes
    },
    _renderChild: ReactElement.createElement.bind(null, config.render)
  });
  type.defineValues(typeImpl.values);
  type.defineListeners(typeImpl.listeners);
  type.render(typeImpl.render);
  type.willUnmount(typeImpl.willUnmount);
  return type.build();
};

typeImpl = {};

typeImpl.values = {
  child: null,
  _queuedProps: null,
  _nativeProps: function() {
    return NativeProps(this.props, this._propTypes);
  }
};

typeImpl.render = function() {
  var props;
  props = this._nativeProps.values;
  props.ref = onRef.bind(this);
  return this._renderChild(props);
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

onRef = function(view) {
  this.child = view;
  if (view && this._queuedProps) {
    this.child.setNativeProps(this._queuedProps);
    this._queuedProps = null;
  }
};
