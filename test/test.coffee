chai = require 'chai'
extras = require('chai-extras');
chai.use extras
chai.should()
require './validators/test-presence'
require './validators/test-length'
require './test-basic_model'
require './test-custom_validators'