
require "isDev"

assertType = require "assertType"
Property = require "Property"

StyleMap = require "./StyleMap"

module.exports = (type) ->
  type.defineProperties typeImpl.properties
  type.defineMethods typeImpl.methods
  type.willBuild typeImpl.willBuild

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.properties =

  _styles: lazy: ->
    StyleMap @_kind and @_kind.styles

typeImpl.methods =

  defineStyles: (styles) ->
    assertType styles, Object
    @_styles.define styles
    return

  overrideStyles: (styles) ->
    assertType styles, Object
    @_styles.override styles
    return

typeImpl.willBuild = ->

  styles = @_styles
  inherited = @_kind and @_kind.styles

  if not styles
    return if not inherited
    styles = inherited

  @defineStatics { styles }

  if not inherited
    prop = Property { frozen: isDev }
    @defineProperties
      styles: get: ->
        styles = @constructor.styles.bind this
        prop.define this, "styles", styles
