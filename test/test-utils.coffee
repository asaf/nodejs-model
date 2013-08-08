u = require '../lib/utils'
model = require '../lib/index'

describe 'Test Utils', ->
    it 'Test isBlank()', (done) ->
        u.isBlank('foo').should.equal false
        u.isBlank('').should.equal true
        u.isBlank().should.equal true
        u.isBlank(null).should.equal true
        u.isBlank(undefined).should.equal true

        done()

    it 'Test getTags()', (done) ->
        u.getTags().pos.should.deep.equal ['default']
        u.getTags().neg.should.have.length 0
        u.getTags('foo').pos.should.deep.equal ['foo']
        u.getTags('foo').neg.should.have.length 0
        u.getTags('!foo').pos.should.have.length 0
        u.getTags('!foo').neg.should.deep.equal ['foo']
        u.getTags(['foo']).pos.should.deep.equal ['foo']
        u.getTags(['!foo']).neg.should.deep.equal ['foo']
        u.getTags(['foo', 'bar']).pos.should.deep.equal ['foo', 'bar']
        u.getTags(['!foo', '!bar']).neg.should.deep.equal ['foo', 'bar']
        tags = u.getTags(['!foo', 'baz', '!bar', 'qux'])
        tags.neg.should.deep.equal ['foo', 'bar']
        tags.pos.should.deep.equal ['baz', 'qux']

        done()

    it 'Confict in tags should cause exception', (done) ->
        try
            u.getTags(['foo','bar','!foo'])
        catch e
            done()

    it 'Test isAttributeMatchesTags()', (done) ->
        #--two tag--
        P = model("Person").attr("name", {tags: ['foo', 'bar']})
        #match attribute if it has 'foo'/'bar' tag.
        u.isAttributeMatchesTags(P, 'name', 'foo').should.equal true
        u.isAttributeMatchesTags(P, 'name', 'bar').should.equal true
        u.isAttributeMatchesTags(P, 'name', ['foo', 'bar']).should.equal true
        u.isAttributeMatchesTags(P, 'name', ['foo', 'baz', 'qux']).should.equal true
        #match attribute if it has 'fo' tag.
        u.isAttributeMatchesTags(P, 'name', 'fo').should.equal false
        #match attribute if it has 'bar'/'baz' but doesnt have the 'foo' tag.
        u.isAttributeMatchesTags(P, 'name', ['baz', 'bar', '!foo']).should.equal false
        #match attr if it doesnt have the 'blabla/a' tags
        u.isAttributeMatchesTags(P, 'name', '!blabla').should.equal true
        u.isAttributeMatchesTags(P, 'name', '!a').should.equal true
        u.isAttributeMatchesTags(P, 'name', ['!a','!blabla']).should.equal true

        done()