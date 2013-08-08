u = require 'util'
model = require '../lib/index'

describe 'Model creations', ->
    it 'model should be a factory function', (done) ->
        if typeof(model) is 'function'
            done()

    it 'Create a basic model', (done) ->
        foo = model("Foo")
        foo.getType().should.equal 'Foo'
        foo.attrsDefs().should.deep.equal {}
        done()

    it 'model should be created with simple attributes, chained', (done) ->
        foo = model("Foo")
            .attr('id')
            .attr('content')

        foo.attrsDefs().should.have.property('id')
        foo.attrsDefs().should.have.property('content')

        done()

    it 'Model should be created with meta attributes, chained', (done) ->
        meta =
            validations:
                presence:
                    message: 'required!'
                converters:
                    to_capital: true
        foo = model("Foo")
            .attr('id', meta
            )
            .attr('content')

        foo.attrsDefs().id.should.deep.equal meta
        done()

    it 'Instantiating a model instance', (done) ->
        P = model("Person")
            .attr('id')
            .attr('name')

        p = P.create()
        if p.id() isnt undefined
            throw 'p.id() Should be undefined!'
        p.id('1').name('foo')
        #By default models instances are indicated as new
        p.isNew().should.equal true

        p.id().should.equal '1'
        p.name().should.equal 'foo'

        done()

    it 'Setting an attribute to null should delete the attribute from the model instance', (done) ->
        P = model("Person").attr('name')

        p1 = P.create()
        p1.name('foo')
        p1.attrs.should.contain.property('name', 'foo')
        p1.name(null)
        p1.attrs.should.not.contain.property('name')
        done()


    it 'Accessors for var_with_underscore should be camelized', (done) ->
        P = model('Person').attr('creation_date')
        p = P.create()
        p.should.not.have.method('creation_date')
        p.should.have.method('creationDate')

        p.creationDate('foo')
        p.creationDate().should.equal 'foo'

        done()

    it 'Initializing model via the init() method', (done) ->
        P = model('Person').attr('name').attr('creation_date')
        d = new Date()
        P.init = (instance) ->
            instance.creationDate(d)

        p1 = P.create()
        p1.creationDate().should.equal d
        done()

    it 'Creating a model instance should produce a create event', (done) ->
        P = model('Person')
            .attr('id')

        P.on('model:created', (p) ->
            p.getType().should.equal 'Person'
            done()
        )

        Post = model('Post')

        Post.on('model:created', () ->
            done()
        )

        P.create()

    it 'Create a model instance by supplying existing object', (done) ->
        Per = model("Person").attr("id").attr("name")

        perObj =
            id: '1'
            name: 'foo'

        p1 = Per.create(perObj)
        p1.id().should.equal '1'
        p1.name().should.equal 'foo'

        done()

    it 'Creating multiple model defs / instances should have different scopes', (done) ->
        Per = model("Person").attr("id").attr("name")
        Post = model("Post").attr("id").attr("body").attr("created_at")

        Object.keys(Per.attrsDefs()).length.should.equal 2
        Per.attrsDefs().should.have.property('id')
        Per.attrsDefs().should.have.property('name')
        Object.keys(Post.attrsDefs()).length.should.equal 3
        Post.attrsDefs().should.have.property('id')
        Post.attrsDefs().should.have.property('body')
        Post.attrsDefs().should.have.property('created_at')

        p1 = Per.create()
        p1.id('1')
        p1.name('foo')

        p2 = Per.create()
        p2.id('2')
        p2.name('bar')

        p1.id().should.equal '1'
        p1.name().should.equal 'foo'
        p2.id().should.equal '2'
        p2.name().should.equal 'bar'

        done()

    it 'Validate a simple model with presence validator', (done) ->
        P = model("Person").attr('name',
            validations:
                presence:
                    message: 'Required!'
        )

        p1 = P.create()
        p1.errors.should.have.length 0
        p1.isValid.should.equal false
        p1.validate().then((validated) ->
            Object.keys(p1.errors).should.have.length 1
            p1.errors.should.deep.equal {name: ['Required!']}
            p1.isValid.should.equal false

            true
        ).then(() ->
            p1.name('foo')
            p1.validate().then((validated) ->
                Object.keys(p1.errors).should.have.length 0
                p1.isValid.should.equal true

                done()
            )
        )

    it 'Ensure validation dont fail when having attributes with _', (done) ->
        P = model("Person").attr('creation_date',
            validations:
                precense:
                    message: 'Required!'
        )

        p1 = P.create()
        p1.creationDate new Date()
        p1.validate().then(() ->
            Object.keys(p1.errors).should.have.length 0
            p1.isValid.should.equal true
            done()
        )

    it 'Validate a model with combined validators', (done) ->
        P = model("Person").attr('name',
            validations:
                presence:
                    message: 'Required!'
        ).attr('title'
            validations:
                length:
                    messages:
                        tooShort: 'too short!'
                        tooLong: 'too long!'
                    minimum: 5
                    maximum: 10
                    allowBlank: false
        )

        p1 = P.create()
        p1.validate().then(() ->
            Object.keys(p1.errors).should.have.length 2
            p1.errors.should.deep.equal { name: [ 'Required!' ], title: [ 'too short!' ] }
            p1.isValid.should.equal false

            true
        ).then(() ->
            p1.title('hello')
            p1.validate().then(() ->
                p1.errors.should.deep.equal {name: ['Required!' ]}

                true
            )
        ).then(() ->
            p1.title('hello-world')
            p1.validate().then(() ->
                p1.errors.should.deep.equal { name: [ 'Required!' ], title: [ 'too long!' ] }
                p1.isValid.should.equal false

                true
            )
        ).then(() ->
            p1.name('foo')
            p1.title('hello')
            p1.validate().then(() ->
                Object.keys(p1.errors).should.have.length 0
                p1.isValid.should.equal true
                done()
            )
        )

    it 'Test TOJSON', (done) ->
        P = model("User").attr("password",
            tags: ['private']
        ).attr("name")

        p1 = P.create()
        p1.name('foo')
        p1.password('secret')
        p1.toJSON().should.deep.equal {name: 'foo'}
        p1.toJSON('private').should.deep.equal {password: 'secret'}
        p1.toJSON('*').should.deep.equal {password: 'secret', name: 'foo'}
        p1.toJSON('!private').should.deep.equal {name: 'foo'}
        p1.toJSON('none').should.deep.equal {}

        done()

    it 'Update model instance via update()', (done) ->
        P = model("Person").attr('name').attr('age')
        .attr('password',
            tags: ['private']
        )

        p1 = P.create()
        p1.name('foo')
        p1.age(10)
        p1.password('secret')

        p1.update(
            name: 'bar'
            age: 20
            password: 'ignore!'
        )

        p1.name().should.equal 'bar'
        p1.age().should.equal 20
        p1.password().should.equal 'secret'

        done()

    it 'Ensure undefined attributes are not causing errors nor updating the model', (done) ->
        P = model("Person").attr('name')
        p1 = P.create()
        p1.name 'foo'

        newObj =
          name: 'bar'
          other: 'baz'

        p1.update(newObj, '*')
        p1.name().should.equal 'bar'
        if p1.other isnt undefined
          throw 'Expected p1.other to be undefined!'
        p1.attrs.should.not.have.property('other')

        done()

    it 'Ensure set model.isNew to false works', (done) ->
        P = model("Person").attr('name')
        p1 = P.create()

        p1.isNew().should.equal true
        p1.setNew(false)
        p1.isNew().should.equal false

        done()
    ###