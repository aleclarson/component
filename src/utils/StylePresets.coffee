
module.exports =

  clear: ->
    backgroundColor: "transparent"

  cover: (enabled) ->
    if enabled
      position: "absolute"
      top: 0
      left: 0
      right: 0
      bottom: 0
    else
      position: null
      top: null
      left: null
      right: null
      bottom: null

  fill: (enabled) ->
    if enabled
      flex: 1
      alignSelf: "stretch"
    else
      flex: null
      alignSelf: null

  leftAlign: ->
    flex: 1
    flexDirection: "row"
    justifyContent: "flex-start"

  rightAlign: ->
    flex: 1
    flexDirection: "row"
    justifyContent: "flex-end"

  centerItems: ->
    alignItems: "center"
    justifyContent: "center"

  size: (size) ->
    width: size
    height: size

  diameter: (size) ->
    width: size
    height: size
    borderRadius: size / 2
