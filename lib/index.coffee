###
# Model Module
#
###
model = require './model'
u = require './utils'
s = require 'stampit'
emitter = require('events').EventEmitter

###
Creates a new model (defnition) with the given type.

@param {String} type of the model
@return {Object} an instantiated model definition
###
create = (type) ->
    if u.isBlank type
        throw {code: 500, message: "Model type is required."}

    m = model.methods(emitter.prototype).create()
    m.setType type
    m

#expose the create factory
module.exports = create