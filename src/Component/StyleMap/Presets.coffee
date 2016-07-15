
module.exports =

  clear: ->
    backgroundColor: "transparent"

  cover: ->
    position: "absolute"
    top: 0
    left: 0
    right: 0
    bottom: 0

  fill: ->
    flex: 1
    alignSelf: "stretch"

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

  diameter: (size) ->
    width: size
    height: size
    borderRadius: size / 2
