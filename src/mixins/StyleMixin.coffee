
{frozen} = require "Property"

assertType = require "assertType"
Builder = require "Builder"
isType = require "isType"

StyleMap = require "../utils/StyleMap"

# This is applied to the Component.Builder constructor
typeMixin = Builder.Mixin()

typeMixin.defineMethods

  defineStyles: (styles) ->
    assertType styles, Object
    cache = @_styles or @_createStyles()
    cache.define styles
    return

  appendStyles: (styles) ->
    assertType styles,  Object
    cache = @_styles or @_createStyles()
    cache.append styles
    return

  overrideStyles: (styles) ->
    assertType styles, Object
    cache = @_styles or @_createStyles()
    cache.override styles
    return

  _createStyles: ->
    kind = @_delegate._kind
    styles = StyleMap kind and kind.styles
    frozen.define this, "_styles", {value: styles}
    return styles

typeMixin.initInstance ->
  @addMixins [instanceMixin.apply]

module.exports = typeMixin.apply

# This is applied to every Component.Builder
instanceMixin = Builder.Mixin()

instanceMixin.willBuild ->

  styles = @_styles
  delegate = @_delegate

  inherited = delegate._kind.styles if delegate._kind
  styles = inherited unless styles or not inherited

  return if not isType styles, StyleMap
  delegate.defineStatics { styles }

  # Only define 'instance.styles' once in the inheritance chain.
  if not inherited
    delegate.definePrototype
      styles: get: ->
        styles = @constructor.styles.bind this
        frozen.define this, "styles", { value: styles }
        return styles
