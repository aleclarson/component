module.exports = {
  clear: function() {
    return {
      backgroundColor: colors.clear
    };
  },
  cover: function() {
    return {
      position: "absolute",
      top: 0,
      left: 0,
      right: 0,
      bottom: 0
    };
  },
  fill: function() {
    return {
      flex: 1,
      alignSelf: "stretch"
    };
  },
  leftAlign: function() {
    return {
      flex: 1,
      flexDirection: "row",
      justifyContent: "flex-start"
    };
  },
  rightAlign: function() {
    return {
      flex: 1,
      flexDirection: "row",
      justifyContent: "flex-end"
    };
  },
  centerItems: function() {
    return {
      alignItems: "center",
      justifyContent: "center"
    };
  },
  diameter: function(size) {
    return {
      width: size,
      height: size,
      borderRadius: size / 2
    };
  }
};

//# sourceMappingURL=../../../../map/src/Component/Style/Presets.map
