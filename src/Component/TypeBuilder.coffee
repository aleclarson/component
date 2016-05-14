
LazyCaller = require "LazyCaller"
assertType = require "assertType"
Reaction = require "reaction"
isType = require "isType"
assert = require "assert"
define = require "define"
guard = require "guard"
Type = require "Type"

type = Type "ComponentTypeBuilder"

type.inherits Type.Builder

type.initInstance ->

  unless isType this, Type.Builder.Kind
    global.failedInstance = this

  @defineReactiveValues
    view: null

  @willBuild ->
    @_buildRender()

type.defineValues

  _loadComponent: null

  _render: null

  _styles: null

  _hasNativeValues: no

  _hasListeners: no

  _hasReactions: no

type.defineMethods

  loadComponent: (loadComponent) ->

    assertType loadComponent, Function
    assert not @_loadComponent, "'loadComponent' is already defined!"
    assert not @_render, "'render' is already defined!"

    # The component class is loaded on first render.
    render = LazyCaller loadComponent

    @_loadComponent = loadComponent
    @_render = (props) ->
      props.context = this
      render props
    return

  render: (render) ->

    assertType render, Function
    assert not @_render, "'render' is already defined!"

    @_render = render
    return

  defineNativeValues: (createNativeValues) ->
    assertType createNativeValues, Function
    throw Error "Not yet implemented!"
    # startReactions()
    # stopReactions()

  defineListeners: (createListeners) ->
    assertType createListeners, Function
    throw Error "Not yet implemented!"
    # startListeners()
    # stopListeners()

  defineReactions: (reactions) ->

    throw Error "Not yet implemented!"

    # assertType reactions, Object
    #
    # unless @_hasReactions
    #   @_hasReactions = yes
    #
    #   @_initInstance ->
    #     define this, "__reactions", Object.create null

    # props = sync.map reactions, (reaction, key) ->
    #   Property

    # @_initInstance ->
    #
    #   Reaction.inject.push "autoStart", yes
    #
    #   for key, createReaction of reactions
    #
    #     assertType createReaction, Function, key
    #
    #     value = createReaction.apply this, args
    #
    #     continue if value is undefined
    #
    #     unless isType value, Reaction
    #       value = Reaction.sync value
    #
    #     assert @__reactions[key] is undefined,
    #       reason: "Conflicting reactions are both named '#{key}'."
    #
    #     @__reactions[key] = value
    #
    #     define this, key, { value, enumerable: no }
    #
    #   Reaction.inject.pop "autoStart"

    # @defineMethods
    #   startReactions: @_startReactions
    #   stopReactions: @_stopReactions

  _startReactions: ->
    throw Error "Not yet implemented!"

  _stopReactions: ->
    throw Error "Not yet implemented!"

  _buildRender: ->
    render = @_render
    return unless render
    @defineMethods
      render: (props) ->
        props = {} unless isType props, Object
        render.call this, props

type.addMixins [
  require "./mixins/Styles"
]

module.exports = type.build()
