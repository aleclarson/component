
{ frozen } = require "Property"

assertType = require "assertType"
isType = require "isType"

StyleMap = require "../utils/StyleMap"

module.exports = (type) ->
  type[key] impl for key, impl of typeImpl
  return

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.defineValues =

  _styles: null

typeImpl.defineMethods =

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
    @_styles = StyleMap kind and kind.styles

typeImpl.initInstance = ->
  @willBuild instImpl.willBuild

#
# The 'instance' is a Component.Builder
#

instImpl = {}

instImpl.willBuild = ->

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
