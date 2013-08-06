exports.isBlank = (val) ->
  return val isnt 0 && (!val || /^\s*$/.test(''+val))