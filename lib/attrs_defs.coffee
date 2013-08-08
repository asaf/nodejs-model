s = require 'stampit'
_s = require 'underscore.string'

#Attributes definitions closure
attrsDefs = s().enclose(() ->
    #a hash of attribute definitions in the notion of attrsDefsHash[attr_name] = meta
    attrsDefsHash = {}
    #the attribute name of the primary key
    primaryKey = null
    #an object contains functions accessors
    accessors = {}

    ###
    Define a new attribute

    @param {String} name attribute name
    @param {Object} meta metadata of the defined attribute including validations rules, sanitization, tags, etc.
    @return {Function} self
    @api public
    ###
    @attr = (name, meta) ->
        attrsDefsHash[name] = meta ?= {}
        if name is '_id' or name is 'id'
            attrsDefsHash[name].primaryKey = true
            primaryKey = name

        #handle tags
        if not meta.tags?
            meta.tags = ['default']

        accessorName =  _s.camelize(name)
        accessors[accessorName] = (value) ->
            #if 0 args its a getter
            if arguments.length is 0
                @attrs[name]
            else
            #otherwise its a setter
                if value is null
                    @dirty[name] = value
                    delete @attrs[name]
                else
                    @dirty[name] = value
                    @attrs[name] = value
                @

        @

    @set = (name, meta) ->
        attrsDefsHash[prop] = value
        @

    @get = (prop) ->
        attrsDefsHash[prop]

    @attrsDefs = () ->
        if arguments.length is 0
            return attrsDefsHash
        else
            return 'NOT SUPPORTED'

    @getAccessors = () ->
        return accessors

    @
)

module.exports = attrsDefs