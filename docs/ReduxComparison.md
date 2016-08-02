
**NOTE:** This is a *very* rough sketch.

---

`Component` is different from [reactjs/redux](https://github.com/reactjs/redux) in many ways.

#### Style

`Component` prefers an object-oriented approach.
- The `props` object and `render` function are coupled with a class instance.
- State management and lifecycle methods are delegated to the class instance.

`Redux` prefers a functional approach.
- The `props` object and `render` function are all there is.
- State management is delegated to "actions", "reducers", and "stores".
- Must use a ReactComponent subclass to get lifecycle methods.

#### Composition

`Component` prefers mostly classes, with some composition sprinkled in.
- Uses class instances to implicitly initialize data.
- Uses reactive variables to implicitly update views.
- Ability to override styles and renderers.

`Redux` prefers mostly composition, with some classes sprinkled in.
- Uses container components to explicitly initialize data.
- Uses `shouldComponentUpdate` to explicitly update views.

#### Mutations

Before we talk about the differences, let's go through some semantics.
- An "implicit mutation" refers to a vanilla setter (eg: `obj.key = newValue`)
- An "explicit mutation" refers to an opaque setter (eg: `store.dispatch(action)`)

`Component` prefers implicit mutations.
- Uses `Object.defineProperty` to preserve a vanilla setter.

`Redux` prefers explicit mutations.
- An "action" represents an explicit mutation (or an explicit batch of implicit mutations).
- A "reducer" is a `Function` that takes an action and performs any amount of implicit mutations.
