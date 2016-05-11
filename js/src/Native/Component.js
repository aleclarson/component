var Component, NativeComponent, NativeProps, ReactElement, assertType, combine, define, isType, ref, steal, sync, throwFailure;

require("isDev");

ReactElement = require("ReactElement");

ref = require("type-utils"), isType = ref.isType, assertType = ref.assertType;

throwFailure = require("failure").throwFailure;

combine = require("combine");

define = require("define");

steal = require("steal");

sync = require("sync");

NativeProps = require("./Props");

Component = require("../Component");

module.exports = NativeComponent = function(name, render) {
  var component;
  assertType(name, String);
  assertType(render, Function);
  component = Component("NativeComponent_" + name, {
    initValues: function() {
      return {
        child: null,
        _queuedProps: null,
        _nativeProps: NativeProps(this.props, render.propTypes)
      };
    },
    initListeners: function() {
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
    },
    componentWillReceiveProps: function(props) {
      return this._nativeProps.attach(props);
    },
    componentWillUnmount: function() {
      return this._nativeProps.detach();
    },
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
  });
  component.propTypes = render.propTypes;
  return component;
};

//# sourceMappingURL=../../../map/src/Native/Component.map
