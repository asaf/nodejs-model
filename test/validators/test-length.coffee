v = require '../../lib/validators/length'
model = require '../../lib/index'

m = null
describe 'Length validator tests', ->
  beforeEach (done) ->
    M = model("M").attr('name')
    m = M.create()

    done()

  describe 'Is tests', ->
    it 'When is: 4 and value length is 4', (done) ->
      options =
        messages:
          wrongLength: 'wrong length'
        is: 4

      m.name('foob')
      v.length(m, 'name', options).then(() ->
        m.errors.should.deep.equal {}
        done()
      )

    it 'When is: 4 and value length is 5 (longer) but no message defined', (done) ->
      options =
        is: 4

      m.name('foobz')
      v.length(m, 'name', options).then(() ->
        m.errors.name.should.deep.equal ['length is incorrect']
        done()
      )

    it 'When is: 4 and value length is 3 (shorter) and message defined', (done) ->
      options =
        messages:
          wrongLength: 'wrong'
        is: 4

      m.name('foo')
      v.length(m, 'name', options).then(() ->
        m.errors.name.should.deep.equal ['wrong']
        done()
      )

    it 'When is: 3 and value is blank, (absence of allowBlank=true eq blank not allowed)', (done) ->
      options =
        messages:
          wrongLength: 'wrong'
        is: 3

      v.length(m, 'name', options).then(() ->
        m.errors.name.should.deep.equal ['wrong']
        done()
      )

    it 'When is:3 and allowBlank=true, value is blank', (done) ->
      options =
        is: 3
        allowBlank: true

      v.length(m, 'name', options).then(() ->
        m.errors.should.deep.equal {}
        done()
      )

    it 'When minimum: 5 and size is 5', (done) ->
      describe 'Minimum, Maximum', ->
      options =
        minimum: 5

      m.name('fooba')
      v.length(m, 'name', options).then((success) ->
        m.errors.should.deep.equal {}
        done()
      )

    it 'When minimum: 5 and size is 4', (done) ->
      describe 'Minimum, Maximum', ->
      options =
        messages:
          tooShort: 'wrong!'
        minimum: 5

      m.name('foob')
      v.length(m, 'name', options).then((success) ->
        m.errors.name.should.deep.equal ['wrong!']
        done()
      )

    it 'When minimum: 3, maximum: 5, value is: 6', (done) ->
      describe 'Minimum, Maximum', ->
      options =
        messages:
          tooLong: 'long!'
        minimum: 3
        maximum: 5

      m.name('foobar')
      v.length(m, 'name', options).then((success) ->
        m.errors.name.should.deep.equal ['long!']
        done()
      )
