
type.defineProps
  variant: Object

# Define static styles.
type.defineStyles

  ".select.active":
    pointerEvents: "none"

  ".select span":
    fontSize: 12

# Define per-render styles.
# You must only use props.
type.defineStyles (props) ->

  ".select.active":
    backgroundColor: props.activeColor

type.render ->
  return MyComponent
    styles: @styles # Extend this component with our styles.
    children: [
      @_renderOption props.variant
    ]

type.defineMethods

  _renderOption: (variant) ->

    text = TextView
      text: variant.title

    return View
      key: variant.id # Use `find` with a leading # to get a view by its key. Must be globally unique.
      class: "select"
      children: [text]

#
# Prototype
#

type.defineMethods

  foo: ->
    # Get rendered component.
    view = @root

    # Find a view by its class.
    view = @find ".select.active"

    # Find all views by class.
    views = @findAll ".select"

    # Get/set native style props.
    view.style.marginTop = 10

    # Manipulate props.
    view.selected = yes

    # Reuse animation configuration.
    config =
      fromValue: 10
      toValue: 20
      duration: 1000 # ms

    # Animate a prop.
    view.animate "style.marginTop", TimingAnimation config

    # Animate many props.
    view.animate
      "style.marginBottom": TimingAnimation config
      "style.marginLeft": TimingAnimation config, {duration: 500} # Extend reused config.
