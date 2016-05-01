
StyleMap = require "../StyleMap"

module.exports = (type) ->

  type.defineProperties typeProps

  type.defineMethods typeMethods

typeProps =

  _styles: lazy: ->

    styles = StyleMap @_kind.styles

    @initType (type) ->
      type.styles = styles

    @initInstance ->
      @styles = styles.build this

    return styles

typeMethods =

  defineStyles: (styles) ->
    assertType styles, Object
    @_styles.define styles
    return

  overrideStyles: (styles) ->
    assertType styles, Object
    @_styles.override styles
    return
