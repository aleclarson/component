
assertType = require "assertType"
Property = require "Property"
isType = require "isType"

StyleMap = require "./StyleMap"

frozen = Property { frozen: yes }

module.exports = (type) ->
  type.defineValues typeImpl.values
  type.defineMethods typeImpl.methods
  type.initInstance typeImpl.initInstance

#
# The 'type' is the Component.Builder constructor
#

typeImpl = {}

typeImpl.values =

  _styles: null

typeImpl.methods =

  defineStyles: (newStyles) ->
    assertType newStyles, Object
    styles = @_styles or @_createStyles()
    styles.define newStyles
    return

  overrideStyles: (newStyles) ->
    assertType newStyles, Object
    styles = @_styles or @_createStyles()
    styles.override newStyles
    return

  _createStyles: ->
    kind = @_delegate._kind
    @_styles = StyleMap kind and kind.styles

typeImpl.initInstance = ->
  @_willBuild.push instImpl.willBuild

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
        frozen.define this, "styles", styles
        return styles
