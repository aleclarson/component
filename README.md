
# component v1.0.0 [![stable](http://badges.github.io/stability-badges/dist/stable.svg)](http://github.com/badges/stability-badges)

- This is compatible with React Native >= 0.19.0

- This package was designed with [CoffeeScript](https://github.com/jashkenas/coffeescript/) in mind.

```sh
npm install aleclarson/component#1.0.0
```

### Exports

```coffee
require "component/global"
```

All exports are implicitly lazy-loaded using `Object.defineProperty`.

**Component**: Creates a `Factory` that spits out `ReactElement` instances.

**NativeComponent**: Wraps a native component for integration with `NativeProps`.

**NativeValue**: Wraps any value that needs to bypass `setState` by using `setNativeProps`.

**Style**: A type validator for `style`-like properties.

**Children**: A type validator for `children`-like properties.

**React**: Contains all `react-native` exports.

**View**: The `React.View` factory wrapped by `NativeComponent`.

**ImageView**: The `React.ImageView` factory wrapped by `NativeComponent`.

**TextView**: The `React.TextView` factory wrapped by `NativeComponent`.

**TextInput**: The `React.TextInput` factory wrapped by `NativeComponent`.

**ScrollView**: The `React.ScrollView` factory wrapped by `NativeComponent`.

**ListView**: The `React.ListView` factory wrapped by `NativeComponent`.

**WebView**: The `React.WebView` factory wrapped by `NativeComponent`.

**Touchable**: The same as `React.TouchableWithoutFeedback`.

**InteractionManager**: The same as `React.InteractionManager`.

**PanResponder**: The same as `React.PanResponder`.

**Easing**: The same as `React.Easing`.

**Interpolation**: The same as `React.Interpolation`.

**NativeModules**: The same as `React.NativeModules`.

---

More documentation coming at a later date. :grin:
