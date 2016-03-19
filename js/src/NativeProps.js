var Children, Factory, NativeMap, NativeStyle, Style, isType;

isType = require("type-utils").isType;

Factory = require("factory");

NativeStyle = require("./NativeStyle");

NativeMap = require("./NativeMap");

Children = require("./Children");

Style = require("./Style");

module.exports = Factory("NativeProps", {
  kind: NativeMap,
  create: function() {
    return NativeMap({});
  },
  initValues: function(props, types, setNativeProps) {
    return {
      _types: types,
      _setNativeProps: setNativeProps
    };
  },
  init: function(props) {
    return this.attach(props);
  },
  _didSet: function(newValues) {
    this._setNativeProps(newValues);
    return this.didSet.emit(newValues);
  },
  _attachValue: function(value, key) {
    var type;
    type = this._types[key];
    if ((type === Children) || (key === "children")) {
      this._values[key] = value;
      return;
    }
    if ((type === Style) || (key === "style")) {
      if (value == null) {
        return;
      }
      try {
        assert(isType(value, Style), {
          value: value,
          props: this,
          reason: "Invalid style!"
        });
      } catch (_error) {}
      if (this._nativeMaps[key] != null) {
        return;
      }
      value = NativeStyle(value);
    }
    return NativeMap.prototype._attachValue.call(this, value, key);
  }
});

//# sourceMappingURL=../../map/src/NativeProps.map
