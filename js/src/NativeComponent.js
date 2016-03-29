var Component, NativeComponent, NativeProps, ReactElement, assertType, combine, define, isDev, isType, ref, steal, sync, throwFailure;

ReactElement = require("ReactElement");

ref = require("type-utils"), isType = ref.isType, assertType = ref.assertType;

throwFailure = require("failure").throwFailure;

combine = require("combine");

define = require("define");

steal = require("steal");

isDev = require("isDev");

sync = require("sync");

NativeProps = require("./NativeProps");

Component = require("./Component");

module.exports = NativeComponent = function(name, render) {
  var component;
  assertType(name, String);
  assertType(render, Function);
  component = Component("NativeComponent_" + name, {
    initValues: function() {
      return {
        child: null,
        _newProps: null,
        _nativeProps: NativeProps(this.props, render.propTypes, (function(_this) {
          return function(newProps) {
            var error;
            if (isDev) {
              try {
                return _this.setNativeProps(newProps);
              } catch (_error) {
                error = _error;
                return throwFailure(error, {
                  component: _this,
                  newProps: newProps
                });
              }
            } else {
              return _this.setNativeProps(newProps);
            }
          };
        })(this))
      };
    },
    setNativeProps: function(newProps) {
      if (this.child != null) {
        return this.child.setNativeProps(newProps);
      }
      return this._newProps = newProps;
    },
    componentWillReceiveProps: function(props) {
      return this._nativeProps.attach(props);
    },
    componentWillUnmount: function() {
      return this._nativeProps.detach();
    },
    render: function() {
      var props;
      props = this._nativeProps.values;
      props.ref = (function(_this) {
        return function(view) {
          _this.child = view;
          if (view && _this._newProps) {
            _this.child.setNativeProps(_this._newProps);
            return _this._newProps = null;
          }
        };
      })(this);
      return ReactElement.createElement(render, props);
    }
  });
  component.propTypes = render.propTypes;
  return component;
};

//# sourceMappingURL=../../map/src/NativeComponent.map
