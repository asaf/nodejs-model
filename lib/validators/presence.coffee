Q = require 'q'
v = require 'validator'
m = require '../messages'

exports.presence = (model_instance, property, options) ->
  d = Q.defer()

  options = {} if options is true

  if !options.message?
    options.message = m.messages.blank

  try
    v.check(model_instance[property]()).notNull()
  catch e
    model_instance.addError(property, options.message)

  d.resolve()
  d.promise