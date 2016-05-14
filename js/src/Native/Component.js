var Component, NativeComponent, NativeProps, ReactElement, assertType, createListeners, instanceMethods, instanceValues, throwFailure, willReceiveProps, willUnmount;

throwFailure = require("failure").throwFailure;

ReactElement = require("ReactElement");

assertType = require("assertType");

NativeProps = require("./Props");

Component = require("../Component");

module.exports = NativeComponent = function(render) {
  var type;
  assertType(render, Function);
  type = Component();
  type.defineFrozenValues({
    _render: render
  });
  type.didBuild(function(type) {
    return type.propTypes = render.propTypes;
  });
  type.defineValues(instanceValues);
  type.defineMethods(instanceMethods);
  type.createListeners(createListeners);
  type.willReceiveProps(willReceiveProps);
  type.willUnmount(willUnmount);
  return type.build();
};

instanceValues = {
  child: null,
  _queuedProps: null,
  _nativeProps: function() {
    return NativeProps(this.props, this._render.propTypes);
  }
};

instanceMethods = {
  onRef: function(view) {
    this.child = view;
    if (view && this._queuedProps) {
      this.child.setNativeProps(this._queuedProps);
      return this._queuedProps = null;
    }
  },
  render: function() {
    var props;
    props = this._nativeProps.values;
    props.ref = (function(_this) {
      return function(view) {
        return _this._onRef(view);
      };
    })(this);
    return ReactElement.createElement(render, props);
  }
};

createListeners = function() {
  return this._nativeProps.didSet((function(_this) {
    return function(newProps) {
      return guard(function() {
        if (_this.child !== null) {
          return _this.child.setNativeProps(newProps);
        } else {
          return _this._queuedProps = newProps;
        }
      }).fail(function(error) {
        return throwFailure(error, {
          component: _this,
          newProps: newProps
        });
      });
    };
  })(this));
};

willReceiveProps = function(props) {
  return this._nativeProps.attach(props);
};

willUnmount = function() {
  return this._nativeProps.detach();
};

//# sourceMappingURL=../../../map/src/Native/Component.map
