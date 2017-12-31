
# TODO: Change example domain, since it's better to couple a `Product` with its components.

# NOTE: Should providers be pass-through when using `find`?

# App-specific data providers
type = Provider()

# Props should be app-specific, or passed down to the rendered component.
type.defineProps
  product: Product

# Providers are restricted to one component type.
# Components have the responsibility of rendering logic.
# This decouples the model and the view.
type.render MyComponent, (props) ->
  title: props.product.title

# Providers have access to global data.
type.selectValues ["cart"]

# Listen to events emitted by the component.
type.defineListeners

  "add": (quantity) ->
    @cart.add @product, quantity
