v = require '../../lib/validators/format'
model = require '../../lib/index'

m = null
describe 'Format validator tests', ->
    beforeEach (done) ->
        M = model("M").attr('name').attr('age')
        m = M.create()
        done()

    it 'With regexp, value comply', (done) ->
        options =
            "with": /^\d*$/

        m.age 14
        v.format(m, 'age', options).then((validated) ->
            m.errors.should.deep.equal {}
            done()
        )

    it 'With regexp and message, value not comply', (done) ->
        options =
            "with": /^\d*$/
            message: 'failure!'

        m.age 'dooo14'
        v.format(m, 'age', options).then((validated) ->
            m.errors.age.should.deep.equal ['failure!']
            done()
        )

    it 'When regexp, not allowing blanks, value is blank', (done) ->
        options =
            "with": /^\d*$/
            message: 'failure!'

        v.format(m, 'age', options).then((validated) ->
            m.errors.age.should.deep.equal ['failure!']
            done()
            )

    it 'When regexp, allowing blanks, value is blank', (done) ->
        options =
            allowBlank: true
            "with": /^\d*$/

        v.format(m, 'age', options).then((validated) ->
            m.errors.should.deep.equal {}
            done()
        )