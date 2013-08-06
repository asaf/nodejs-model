v = require '../../lib/validators/presence'
model = require '../../lib/index'

m = null
describe 'Presence validator tests', ->
    beforeEach (done) ->
        M = model("M").attr('name')
        m = M.create()
        done()

    it 'Positive test where value exist', (done) ->
        m.name('Some Value')
        options =
            message: 'failed validation'

        v.presence(m, 'name', options).then(() ->
            m.errors.should.deep.equal {}
            done()
        )

    it 'Negative test when options is true', (done) ->
        options = true
        v.presence(m, 'name', options).then(() ->
            m.errors.should.deep.equal {name: ['can\'t be blank']}
            done()
        )

    it 'Negative test when value is empty and options is object with message property', (done) ->
        options =
            message: 'missing'

        v.presence(m, 'name', options).then(() ->
            m.errors.should.deep.equal {name: ['missing']}
            done()
        )