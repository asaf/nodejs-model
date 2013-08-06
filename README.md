nodejs-model
==========

Okay, so you have a node app backed with some kind of NoSQL schema-less DB such as CouchDB and it all works pretty well,

But hey, even though schema-less is very cool and produces fast results, for small apps it makes sense, but while application code
grows more and more, you will end with low data integrity and things will start to become messy,


So this is what nodejs-model is for, its a super minimal, extensible model structure for node, it doesn't dictate any requirements
on the DB level, it's just a plain javascript object with some enhanced capabilities for validations and filtering.

Note: It is heavily inspired by Ruby AcitveObject Validations but is enhanced with more capabilities than validations such
as filtering and sanitization.


Why use nodejs-model?
===================

If one or more of the bullets below makes sense to you, then you should try nodejs-model.

* Model attributes: A lightweight javascript model with simple accessors.
* Attribute validations: define validation rules per defined attribute.
* Accessibility control: Sometimes your models may contain sensitive data (such as a 'password'/'token' attributes) and you want a simple way to filter such properties based on tags.
* Events: Events are fired when objects are being created or properties are modified.

Basic Usage
===========

This is how it works:

Create a _model_ definition with some validation rules

``` javascript
var model = require('nodejs-model');

//create a new model definition _User_ and define _name_/_password_ attributes
var User = model("User").attr('name', {
  validations: {
    presence: {
      message: 'Name is required!'
    }
  }
}).attr('password', {
  validations: {
    length: {
      minimum: 5,
      maximum: 20,
      messages: {
        tooShort: 'password is too short!',
        tooLong: 'password is too long!'
      }
    }
  },
  //this tags the accessibility as _private_
  accessibility: ['private']
});

var u1 = User.create();
//getters are generated automatically
u1.name('foo');
u1.password('password');

u1.name()
//prints _foo_

//Invoke validations and wait for the validations to fulfill
u1.validate(function() {
  if u1.isValid {
     //validated, perform business logic
  } else {
     //validation failed, dump validation errors to the console
     console.log(p1.errors)
  }
});

//get object as a plain object, ready for JSON
u1.toJSON();
//produces: { name: 'foo' }

//now also with attributes that their accessibility is 'private'
u1.toJSON('private')
//produces: { name: 'foo' } { password: 'password' }
```

Simple as that, your model is enhanced with a validate() method, simply invoke it to validate the model object
against the validation rules defined in the schema.
