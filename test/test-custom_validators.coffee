u = require 'util'
model = require '../lib/index'

describe 'Custom Validators', ->
    it 'Test custom validator per Model', (done) ->
        P = model("Person").attr('id')
        .attr('name',
            validations:
                presence: true
                uniqueUserName:
                    message: 'Name already exist.'
        )

        P.validator('uniqueUserName', (model, property, options) ->
            model.name().should.equal 'foo'
            property.should.equal 'name'
            options.should.deep.equal { message: 'Name already exist.' }

            if model[property]() is 'foo'
                model.addError property, options.message
        )

        p1 = P.create()
        p1.name 'foo'
        p1.validate().then(() ->
            p1.isValid.should.equal false
            p1.errors.should.deep.equal { name: [ 'Name already exist.' ] }
            done()
        )