
ReactComponent = require "ReactComponent"
Type = require "Type"

type = Type "Component"

type.inherits ReactComponent

type.returnExisting -> Component.Builder()

type.defineProperties

  view: get: ->
    @context.view or this

  context: get: ->
    @props.context or this

type.defineStatics

  Builder: lazy: ->
    require "./Builder"

  Type: lazy: ->
    require "./Type"

  StyleMap: lazy: ->
    require "./StyleMap"

  traverseParents: (component) ->
    results = []
    loop
      results.push component
      owner = component._reactInternalInstance._currentElement._owner
      break unless owner
      component = owner._instance
    return results

type.initInstance ->
  @context.view = this

type.defineMethods

  componentDidMount: ->

  componentDidUnmount: ->

module.exports = Component = type.build()
