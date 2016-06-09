
# TODO: Write tests.

# require("./lotus-require").register()
#
# StyleMap = require "component/js/src/Component/StyleMap"
#
# StyleMap.addPresets
#
#   cover:
#     position: "absolute"
#     top: 0
#     left: 0
#     right: 0
#     bottom: 0
#
# map = StyleMap()
#
# map.define
#
#   foo:
#     width: -> @width
#     opacity: 0.5
#     scale: 0.5
#
# styles = map.bind
#
#   width: 100
#
#   styles:
#
#     foo:
#       opacity: 1
#
#     bar:
#       cover: yes
#
# log = require "log"
#
# try log.format styles.foo(), { label: "styles.foo = ", maxObjectDepth: Infinity }
#
# try log.format styles.bar(), { label: "styles.bar = ", maxObjectDepth: Infinity }
#
# log.format map._constantStyles, { label: "map._constantStyles = ", maxObjectDepth: Infinity }
#
# log.format map._computedStyles, { label: "map._computedStyles = ", maxObjectDepth: Infinity }
