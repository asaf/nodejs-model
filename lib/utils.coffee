_ = require 'underscore'

exports.isBlank = (val) ->
  return val isnt 0 && (!val || /^\s*$/.test(''+val))

exports.grep = (elems, callback, inv) ->
  retVal = undefined
  ret = []
  i = 0
  length = elems.length
  inv = !!inv

  # Go through the array, only saving the items
  # that pass the validator function
  while i < length
    retVal = !!callback(elems[i], i)
    ret.push elems[i]  if inv isnt retVal
    i++
  ret

exports.getTags = (tags) ->
    negTags = (inv=false) ->
        exports.grep(tags, (ele) ->
            ele.indexOf('!') is 0
        , inv)

    if exports.isBlank tags
        {pos: ['default'], neg: []}
    else if tags.constructor isnt Array
        if tags.indexOf('!') is 0
            {neg: [tags.slice(1,tags.length)], pos: []}
        else
            {pos: [tags], neg: []}
    else
        #TODO: else ensure each tag is a string
        neg = negTags()
        pos = negTags(true)

        for k,v of neg
            neg[k] = v.slice(1, v.length)

        if _.intersection(pos, neg).length > 0
            throw 'Intersection is not allowed.'
        else
            {pos: pos, neg: neg}

exports.isAttributeMatchesTags = (model, attrName, tags) ->
    attrTags = exports.getTags(model.attrsDefs()[attrName].tags).pos
    tagsReq = exports.getTags(tags)

    #console.log 'ATTR TAGS: ', attrTags
    #console.log 'REQ TAGS: ', tagsReq

    #In case we only recieve negative tags, we assume it's been read as: 'Gimme everything BUT !negative !tags'
    if tagsReq.neg.length > 0 and tagsReq.pos.length is 0
        tagsReq.pos.push('*')

    ack = false

    if _.contains(tagsReq.pos, '*') or _.intersection(tagsReq.pos, attrTags).length > 0
        ack = true

    if ack
        if _.intersection(tagsReq.neg, attrTags).length > 0
            ack = false

    ack