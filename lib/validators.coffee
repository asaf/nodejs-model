require("fs").readdirSync(__dirname + "/validators").forEach (file) ->
  if file.match(/.+\.coffee/g) isnt null
    name = file.replace(".coffee", "")
    exports[name] = require("./validators/" + file)[name]
