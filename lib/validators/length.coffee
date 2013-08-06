Q = require 'q'
v = require 'validator'
m = require '../messages'
u = require '../utils'

exports.length = (model, property, options) ->
  d = Q.defer()

  #options may contain the following types
  TYPES =
    'is'      : '==' #exact expected length
    'minimum' : '>=' #minumum length allowed
    'maximum' : '<=' #maximum length allowed

  #message key per type
  MESSAGES =
    'is'      : 'wrongLength', #The error message key when 'is' used.
    'minimum' : 'tooShort', #The error message key when minimum is used.
    'maximum' : 'tooLong' #The error message kwy when maximum is used.

  keys = Object.keys(MESSAGES)

  if options.messages is undefined
    options.messages = {}

  #If options is 'length: x' then define 'is= x'
  if typeof(options) is 'number'
    options =
      'is': options


  #options may be {is: x} or {minimum: x, maximum y}, it may also be defined with messages object such as:
  ##{minimum: x, maximum y, messages {tooShort: 'value must be at least X chars length}
  #in case options contains a TYPE but corresponding message doesnt exist, then get the default message for the
  #corresponding type.
  index = 0
  while index < keys.length
    key = keys[index]
    if options[key] isnt `undefined` and options.messages[MESSAGES[key]] is `undefined`
      options.messages[MESSAGES[key]] = m.messages[MESSAGES[key]]
    index++

  #default tokenizier is none, but may recieve one externally
  tokenizer = options.tokenizer or 'split("")'
  tokenizedLength = new Function("value", "return value." + tokenizer + ".length")(model[property]() or "")

  allowBlankOptions = {}
  if options.is
    allowBlankOptions.message = options.messages.wrongLength
  else allowBlankOptions.message = options.messages.tooShort if options.minimum

  if u.isBlank(model[property]())
    model.addError property, allowBlankOptions.message if not options.allowBlank and (options.is or options.minimum)
  else
    for check of TYPES
      oper = TYPES[check]
      continue unless options[check]
      fn = new Function("return " + tokenizedLength + " " + oper + " " + options[check])
      model.addError property, options.messages[MESSAGES[check]] unless fn()

  d.resolve()
  d.promise