
# modx v2.0.1 ![experimental](https://img.shields.io/badge/stability-experimental-EC5315.svg?style=flat)

> Model-backed components for [React Native](https://github.com/facebook/react-native)

```sh
npm install modx --save
```

## Component.Type

Every model-backed component relies on the `Component.Type` constructor.
It assists in building the factory that creates both your models and their component instances.

```coffee
{Component} = require "modx"

type = Component.Type "Foo"
```

*Note: Naming the type is optional.*

The first thing every component model needs is a `render` method.

```coffee
type.render ->
  # TODO: Create and return a `ReactElement`.
  return false # <= Render nothing for now.
```

Before we learn anything else, let's finalize our model factory so we can try the `render` method.

```coffee
# Finalize the model factory.
Foo = type.build()

# Initialize a model instance.
foo = Foo()

foo.render() # => false
```

Using model-backed components means you can:

- Re-render without using `setState`

- Avoid the `ref` callback (you already have the model, which has access to its view)

- And more... (which I'll add here at a later date)

---

#### TODO: Write more docs...
