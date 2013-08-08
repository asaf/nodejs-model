u = require 'util'
model = require '../lib/index'

describe 'Conditional Validators', ->
    it 'Ensure conditional Validator represented as an inline IF function is executed.', (done) ->
        p1 = null
        P = model("Person").attr('id').attr('name',
            validations:
                presence:
                    message: 'required!'
                    if: (model, validator) ->
                        model.should.deep.equal p1
                        if typeof(validator.constructor) is 'function'
                            done()
        )

        p1 = P.create()
        p1.id '1234-4321'
        p1.validate()

    it 'Ensure conditional validator represented as an inline IF function works as expected.', (done) ->
        P = model("Person").attr('name',
            validations:
                length:
                    is: 9
                    message: '9 length exepcted!'
                    if: (model, validator) ->
                        if model.name() is 'foo'
                            true
                        else
                            false
        )

        p1 = P.create()
        p1.name 'foo'

        p1.validate().then(() ->
            p1.isValid.should.equal false

            p1.name 'other'
            p1.validate().then(() ->
                p1.isValid.should.equal true
                done()
            )
        )

    #TODO:
    #it 'Ensure conditional Validator represented as an IF function in the model works as expected.', (done) ->
    #TODO:
    #it 'Ensure conditional Validator represented as an IF property in the model works as expected.', (done) ->
    #TODO:
    #it 'Ensure validator is executed in case IF property is malformed (not an inline fn, nor model.func or model property value as fn)'


    it 'Ensure conditional validator represented as inline UNLESS function is executed', (done) ->
        p1 = null
        P = model("Person").attr('id').attr('name',
            validations:
                presence:
                    message: 'required!'
                    unless: (model, validator) ->
                        model.should.deep.equal p1
                        if typeof(validator.constructor) is 'function'
                            done()
        )

        p1 = P.create()
        p1.id '1234-4321'
        p1.validate()

    it 'Ensure conditional validator represented as an inline UNLESS function works as expected.', (done) ->
        P = model("Person").attr('name',
            validations:
                length:
                    is: 9
                    message: '9 length exepcted!'
                    unless: (model, validator) ->
                        if model.name() is 'foo'
                            false
                        else
                            true
        )

        p1 = P.create()
        p1.name 'foo'

        p1.validate().then(() ->
            p1.isValid.should.equal false

            p1.name 'other'
            p1.validate().then(() ->
                p1.isValid.should.equal true
                done()
            )
        )

    #TODO:
    #it 'Ensure conditional Validator represented as an UNLESS function in the model works as expected.', (done) ->
    #TODO:
    #it 'Ensure conditional Validator represented as an UNLESS property in the model works as expected.', (done) ->
    #TODO:
    #it 'Ensure validator is executed in case UNLESS property is malformed (not an inline fn, nor model.func or model property value as fn)'
