var Component, NativeComponent, NativeProps, ReactElement, combine, define, isType, reportFailure, steal, sync;

ReactElement = require("ReactElement");

isType = require("type-utils").isType;

sync = require("io").sync;

reportFailure = require("report-failure");

combine = require("combine");

define = require("define");

steal = require("steal");

NativeProps = require("./NativeProps");

Component = require("./Component");

module.exports = NativeComponent = function(name, render) {
  return Component("NativeComponent_" + name, {
    statics: {
      propTypes: render.propTypes
    },
    initValues: function() {
      return {
        childView: null,
        _nativeProps: NativeProps(this.props, render.propTypes, (function(_this) {
          return function(newProps) {
            var error;
            if (_this.props.DEBUG) {
              _this._newValues.push(newProps);
            }
            try {
              return _this.childView.setNativeProps(newProps);
            } catch (_error) {
              error = _error;
              return reportFailure(error, {
                component: _this
              });
            }
          };
        })(this))
      };
    },
    init: function() {
      var props;
      props = this.props;
      return define(this, function() {
        this.options = {
          enumerable: false,
          frozen: true
        };
        return this(props.DEBUG ? {
          _initialValues: props
        } : void 0, {
          _newValues: [],
          _findNewValue: (function(_this) {
            return function(key) {
              var newValues;
              newValues = [];
              key = key.split(".");
              sync.each(_this._newValues, function(values) {
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
            };
          })(this)
        });
      });
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
          return _this.childView = view;
        };
      })(this);
      return ReactElement.createElement(render, props);
    }
  });
};

//# sourceMappingURL=../../map/src/NativeComponent.map
