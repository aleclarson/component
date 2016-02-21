
ReactElement = require "ReactElement"

{ isType } = require "type-utils"
{ sync } = require "io"

reportFailure = require "report-failure"
combine = require "combine"
define = require "define"
steal = require "steal"

NativeProps = require "./NativeProps"
Component = require "./Component"

module.exports =
NativeComponent = (name, render) ->

  return Component "NativeComponent_" + name,

    statics:

      propTypes: render.propTypes

    initValues: ->

      childView: null

      _nativeProps: NativeProps @props, render.propTypes, (newProps) =>

        # if __DEV__
        @_newValues.push newProps if @props.DEBUG

        try @childView.setNativeProps newProps
        catch error then reportFailure error, { component: this }

    init: ->

      # if __DEV__

      { props } = this

      define this, ->

        @options = { enumerable: no, frozen: yes }
        @
          _initialValues: props if props.DEBUG

          _newValues: []

          _findNewValue: (key) =>
            newValues = []
            key = key.split "."
            sync.each @_newValues, (values) ->
              index = 0
              while index < key.length
                values = values[key[index++]]
                break unless values?
              newValues.push values if values?
            newValues

    componentWillReceiveProps: (props) ->
      @_nativeProps.attach props

    componentWillUnmount: ->
      @_nativeProps.detach()

    render: ->
      props = @_nativeProps.values
      props.ref = (view) => @childView = view
      ReactElement.createElement render, props
