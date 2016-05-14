
StyleMap = require "../StyleMap"

module.exports = (type) ->

  type.defineProperties typeProps

  type.defineMethods typeMethods

typeProps =

  _styles: lazy: ->

    inheritedStyles = if @_kind then @_kind.styles else null

    styles = StyleMap inheritedStyles

    @didBuild (type) ->
      type.styles = styles

    @initInstance ->
      @styles = styles.bind this

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
