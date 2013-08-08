attrsDefs = require './attrs_defs'
u = require './utils'
model_instance = require './model_instance'
s = require 'stampit'
emitter = require('events').EventEmitter

#Model closure
model = s().enclose(() ->
    type = undefined #a string represents the model type
    validators = {}

    @getType = () ->
        type

    @setType = (model_type) ->
        type = model_type

    @init = () ->
        @

    @validators = (default_validators) ->
      if arguments.length is 0
        validators
      else
        validators = default_validators

    @validator = (name, fn) ->
      validators[name] = fn

    #Create a new model instance from this model definition
    @create = (fromObject, tags) ->
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

        if fromObject
            #no tags mean any
            if not tags?
                tags = '*'

            modelInstance.update(fromObject, tags)


        @emit('model:created', modelInstance)

        modelInstance

    @
)

module.exports = s.compose model, attrsDefs