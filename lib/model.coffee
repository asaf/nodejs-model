attrsDefs = require './attrs_defs'
model_instance = require './model_instance'
s = require 'stampit'
emitter = require('events').EventEmitter

#Model closure
model = s().enclose(() ->
    type = undefined #a string represents the model type

    @getType = () ->
        type

    @setType = (model_type) ->
        type = model_type

    @init = () ->
        @

    #Create a new model instance from this model definition
    @create = () ->
        eventsPrototype = emitter.prototype
        objF = s().methods(@getAccessors(), eventsPrototype).state(
            attrs: {}
            dirty: {}
            errors: []
            isValid: false
        )

        staticF = s(model_instance({model: @}))
        objFactory = s.compose(objF, staticF)
        modelInstance = objFactory.create()
        @init(modelInstance)
        @emit('model:created', modelInstance)

        modelInstance

    @
)

module.exports = s.compose model, attrsDefs