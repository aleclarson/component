
require "isDev"

assertType = require "assertType"
Property = require "Property"

StyleMap = require "./StyleMap"

module.exports = (type) ->
  type.defineValues typeValues
  type.defineMethods typeMethods
  type.willBuild typePhases.willBuild
  return 1

typeValues =

  _styles: null

typeMethods =

  defineStyles: (styles) ->
    assertType styles, Object
    @_initStyleMap()
    @_styles.define styles
    return

  overrideStyles: (styles) ->
    assertType styles, Object
    @_initStyleMap()
    @_styles.override styles
    return

  _initStyleMap: ->
    return if @_styles
    @_styles = StyleMap @_kind and @_kind.styles

typePhases =

  willBuild: ->

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
