var Component, NativeComponent, NativeProps, ReactElement, assertType, defineListeners, instanceMethods, instanceValues, throwFailure, willUnmount;

throwFailure = require("failure").throwFailure;

ReactElement = require("ReactElement");

assertType = require("assertType");

NativeProps = require("./Props");

Component = require("../Component");

module.exports = NativeComponent = function(render) {
  var type;
  assertType(render, Function);
  type = Component();
  type.definePrototype({
    _render: render
  });
  type.didBuild(function(type) {
    return type.propTypes = render.propTypes;
  });
  type.defineValues(instanceValues);
  type.defineMethods(instanceMethods);
  type.defineListeners(defineListeners);
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
  render: function() {
    var props;
    props = this._nativeProps.values;
    props.ref = (function(_this) {
      return function(view) {
        return _this._onRef(view);
      };
    })(this);
    return ReactElement.createElement(this._render, props);
  },
  _onRef: function(view) {
    this.child = view;
    if (view && this._queuedProps) {
      this.child.setNativeProps(this._queuedProps);
      return this._queuedProps = null;
    }
  }
};

defineListeners = function() {
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

willUnmount = function() {
  return this._nativeProps.detach();
};

//# sourceMappingURL=../../../map/src/Native/Component.map
