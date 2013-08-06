###
# Model Module
#
###
model = require './model'
u = require './utils'
s = require 'stampit'
emitter = require('events').EventEmitter
Validators = require './validators'

###
Creates a new model (defnition) with the given type.

@param {String} type of the model
@return {Object} an instantiated model definition
###
create = (type) ->
    if u.isBlank type
        throw {code: 500, message: "Model type is required."}

    mF = model.methods(emitter.prototype)
    m = mF.create()

    m.setType type
    m.validators Validators
    m

#expose the create factory
module.exports = create