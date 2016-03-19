var Component, NativeComponent, NativeProps, ReactElement, _initDebug, combine, define, isType, steal, sync, throwFailure;

ReactElement = require("ReactElement");

throwFailure = require("failure").throwFailure;

isType = require("type-utils").isType;

sync = require("io").sync;

combine = require("combine");

define = require("define");

steal = require("steal");

NativeProps = require("./NativeProps");

Component = require("./Component");

module.exports = NativeComponent = function(name, render) {
  var component;
  component = Component("NativeComponent_" + name, {
    initValues: function() {
      return {
        child: null,
        _nativeProps: NativeProps(this.props, render.propTypes, (function(_this) {
          return function(newProps) {
            var error, ref;
            if (_this.props.DEBUG) {
              _this._newValues.push(newProps);
            }
            try {
              return (ref = _this.child) != null ? ref.setNativeProps(newProps) : void 0;
            } catch (_error) {
              error = _error;
              return throwFailure(error, {
                component: _this,
                newProps: newProps
              });
            }
          };
        })(this))
      };
    },
    init: function() {
      return _initDebug.call(this);
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
          return _this.child = view;
        };
      })(this);
      return ReactElement.createElement(render, props);
    }
  });
  component.propTypes = render.propTypes;
  return component;
};

_initDebug = function() {
  var props;
  props = this.props;
  return define(this, function() {
    this.options = {
      enumerable: false,
      frozen: true
    };
    return this({
      _initialValues: (props.DEBUG ? props : void 0),
      _newValues: [],
      _findNewValue: function(key) {
        var newValues;
        newValues = [];
        key = key.split(".");
        sync.each(this._newValues, function(values) {
          var index;
          index = 0;
          while (index < key.length) {
            values = values[key[index++]];
            if (values == null) {
              break;
            }
          }
          if (values != null) {
            return newValues.push(values);
          }
        });
        return newValues;
      }
    });
  });
};

//# sourceMappingURL=../../map/src/NativeComponent.map
