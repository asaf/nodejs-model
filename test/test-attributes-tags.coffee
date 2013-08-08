u = require 'util'
model = require '../lib/index'
_ = require 'underscore'

describe 'Attributes Tags', ->
    it "Ensure default tag is 'default'", (done) ->
        P = model("Person").attr('name').attr('age')
        P.attrsDefs().name.tags.should.deep.equal ['default']
        P.attrsDefs().age.tags.should.deep.equal ['default']

        p1 = P.create()
        p1.name('foo')
        p1.age(1)

        p1Obj =
            name: 'foo'
            age: 1

        p1.toJSON().should.deep.equal p1Obj
        p1.toJSON('default').should.deep.equal p1Obj
        p1.toJSON('priv').should.deep.equal {}

        done()

    #TODO: More tests goes here