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

    #Ensure regexp is valid
    regexpTest = options['with'].test
    if regexpTest is undefined
      throw {code: 500, message: "The specified regexp #{options['with']} is invalid.", status: "failure"}

    if u.isBlank model[property]()
        if not options.allowBlank
            model.addError property, options.message
    else if options['with'] && not options['with'].test model[property]()
        model.addError property, options.message
    else if options.without && options.without.test model[property]()
        model.addError property, options.message

    d.resolve()

    d.promise