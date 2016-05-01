
{ assertType } = require "type-utils"

Reaction = require "../Reaction/Reaction"
define = require "define"
Type = require "Type"

type = Type "ComponentModelBuilder"

type.inherits Type.Builder

type.initInstance ->

  @defineReactiveValues
    view: null

type.defineValues

  _styles: null

  _hasNativeValues: no

  _hasListeners: no

  _hasReactions: no

type.defineMethods

  loadComponent: (loadComponent) ->

    assertType loadComponent, Function

    @initType (type) ->
      render = LazyVar -> loadComponent.call type.prototype
      define type.prototype, "render", (props) ->
        if props
          if ModelContext.current
            props.__context = ModelContext.current

  createNativeValues: (createNativeValues) ->
    assertType createNativeValues, Function
    throw Error "Not yet implemented!"
    # startReactions()
    # stopReactions()

  createListeners: (createListeners) ->
    assertType createListeners, Function
    throw Error "Not yet implemented!"
    # startListeners()
    # stopListeners()

  defineReactions: (reactions) ->

    assertType reactions, Object

    unless @_hasReactions
      @_hasReactions = yes

      @_initInstance ->
        define this, "__reactions", Object.create null

    # props = sync.map reactions, (reaction, key) ->
    #   Property

    @_initInstance ->

      Reaction.inject.push "autoStart", yes

      for key, createReaction of reactions

        assertType createReaction, Function, key

        value = createReaction.apply this, args

        continue if value is undefined

        unless isType value, Reaction
          value = Reaction.sync value

        assert @__reactions[key] is undefined,
          reason: "Conflicting reactions are both named '#{key}'."

        @__reactions[key] = value

        define this, key, { value, enumerable: no }

      Reaction.inject.pop "autoStart"

    # @defineMethods
    #   startReactions: @_startReactions
    #   stopReactions: @_stopReactions

  _startReactions: ->
    throw Error "Not yet implemented!"

  _stopReactions: ->
    throw Error "Not yet implemented!"
