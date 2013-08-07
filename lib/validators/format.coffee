Q = require 'q'
v = require 'validator'
m = require '../messages'
u = require '../utils'

exports.format = (model, property, options) ->
    d = Q.defer()
    if options.constructor is RegExp
        options =
            "with": options

    if !options.message?
        options.message = m.messages.invalid

    if u.isBlank model[property]()
        if not options.allowBlank
            model.addError property, options.message
    else if options['with'] && !options['with'].test model[property]()
        model.addError property, options.message
    else if options.without && options.without.test model[property]()
        model.addError property, options.message

    d.resolve()

    d.promise