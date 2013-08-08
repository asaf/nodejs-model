[![Build Status](https://travis-ci.org/asaf/nodejs-model.png?branch=master)](https://travis-ci.org/asaf/nodejs-model)

# nodejs-model

Okay, so you have a node app backed with some kind of NoSQL schema-less DB such as CouchDB and it all works pretty well,

But hey, even though schema-less is very cool and produces fast results, for small apps it may make sense, but as application 
code grows bigger and bigger, you will eventually end with low data integrity and things will start to become messy,

So this is what nodejs-model is for, it is a very minimal, extensible model structure for node, it doesn't dictate any 
DB requirements nor hook into it directly, it's just a plain javascript object with some enhanced capabilities for 
attributes accessors, validations, tagging and filtering.

Note: If you are aware of Ruby AcitveObject Validations you will probably find some common parts with the 
validation capability of it, But _nodejs-model_ goes much further, read on :-)


# Why use nodejs-model?

If one or more of the bullets below makes sense to you, then you should try nodejs-model.

* Model attributes: A lightweight javascript model with simple accessors.
* Attribute validations: define validation rules per defined attribute.
* Accessibility via tags: Tag attributes with some labels, then allow retrieving/updating only attributes that matches some tags.
* Events: Events are fired when objects are being created or properties are modified.
* Converters: Simply hook converters into attributes, for example an encryptor converter may attach to the _password_ attribute of a _User_ model to encrypt the user's password immediately after it is set with new value.

#Installation

To install nodejs-model, use [npm](http://github.com/isaacs/npm):

```bash
$ npm install nodejs-model --save
```


# Basic Usage

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
  tags: ['private']
});

var u1 = User.create();
//getters are generated automatically
u1.name('foo');
u1.password('password');

console.log(u1.name());
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
console.log(u1.toJSON());
//produces: { name: 'foo' }

//now also with attributes that were tagged with 'private'
console.log(u1.toJSON('private'));
//produces: { name: 'foo' } { password: 'password' }
```


Simple as that, your model is enhanced with a validate() method, simply invoke it to validate the model object
against the validation rules defined in the schema.


# Updating Model Instance

Assuming you have a simple model instance (`u1` as defined in the basic example above, you can update it with new data 
at some point after loading an object from DB / file / JSON / etc:


``` javascript
someObj = {
  name: 'bar',
  password: 'newpassword'
};

u1.update(someObj);

console.log(u1.name());
//prints bar
console.log(u1.password());
//NOTE: prints password
```

Pay attention that password wasn't updated, this is because when invoking `update(object)` only public attributes (any
attribute that its _tags_ metadata wasnt defined or defined as _['default']_ can be updated.

With this specific example, since _password_ is tagged with _private_, you can update by suppling the _private_ tag
to the `update()` 2nd parameter as:

``` javascript
u1.update(someObj, 'private')
console.log(u1.name());
//prints bar
console.log(u1.password());
//NOTE: prints newpassword
```


# Validators

## Presence

The _Presence_ ensure that an attribute value is not null or empty string, example:

```javascript
var User = model("User").attr('name', {
  validations: {
    presence: true
  });
```

### Options

* `true` - value will be required, default message is set.
* `message` - string represents the error message if validator fails.

Example with custom message:

```javascript
validations: {
  presence: {
    message: 'Name is required!'
  }
}
```

## Length

Validates rules of the length of a property value.

### Options

* `is` keyword or `number` - An exact length
* `array` - Will expand to `minimum` and `maximum`. First element is the lower bound, second element is the upper bound.
* `allowBlank` - Validation is skipped if equal to `true` and value is empty
* `minimum` - Minimum length of the value allowed
* `maximum` - Maximum length of the value allowed

### Messages
  * `wrongLength` - any string represents the error message if `is`/`number` validation fails.
  * `tooShort` - any string represents the error message if `minimum` validation fails.
  * `tooLong` - any string represents the error message if `maximum` validation fails.

```javascript
// Examples of is, both are equal, exact 3 length match
length: 3
length: {is: 3}
//same as above, but empty string is allowed
length: { is: 3, allowBlank: true } 
//min legnth: 2, max length: 4
length: [2, 4]
//same as above with custom error messages
length: { minimum: 2, maximum: 4, messages { tooShort: 'min 3 length!', tooLong: 'max 5 length!' } }
```

## Format

Regexp test validator

### Options

* `with` - the regular expression to test
* `allowBlank` - Validation is skipped if equal to `true` and value is empty
* `message` - any string represents the error message.

```javascript
// Examples
format: { with: /^\d*$/, allowBlank: true, message: 'only digits are allowed, or empty string.'  }
```

# Tags

nodejs-model supports tags per defined attribute, when new attribute is defined with no _tags_ it will be automatically
tagged with the _default_ tag.

Methods such as toJSON(tags_array) or `update(updatedObj, tags_array)` are accessbility aware when
updating or producing model instance output.


You can define tags per attribute by:

``` javascript
User = model("User").attr('name', {
  tags: ['ui', 'registered']
}).attr('password', {
  tags: ['private']
}).attr('age');

u1 = User.create();
u1.name('foo');
u1.password('secret');
u1.age(55);

console.log(u1.toJSON());
//prints { age: 55 }, this is because invoking toJSON(), it will only create an object with attributes defined
as public.

console.log(u1.toJSON(['ui', 'private']));
//prints { name: 'foo', password: 'secret' }

//* means any property with any tags
console.log(u1.toJSON('*'));
//prints { name: 'foo', password: 'secret', age: 55 }
```

Update mehtod `someInstance.update(newObj, tags)` is also _tags-aware_ as with `someInstance.toJSON(tags)`.


#Initializing Model Instances

It is possible to initialize a model instance by suppliying an `init` method on the Model level,

Here is an example how to initialize a creation date attribute for a model:

```javascript
var P = model('Person').attr('name').attr('creation_date');

//will be invoked just after a model is instantiated by P.create()
P.init = function(instance) {
  instance.creationDate(d);
};

p1 = P.create();

console.log(p1.creationDate())
//prints a date
```

#More Info
Check wiki pages:

* [Custom Validator per Model](https://github.com/asaf/nodejs-model/wiki/Custom-Validator-per-Model)
* [Conditional Validator](https://github.com/asaf/nodejs-model/wiki/Conditional-Validator)


#Contributers

* [amitpaz](https://github.com/amitpaz) - Co author, design, tests, etc.

#Contributions

You can contribute in few ways:

* Just use the module, this is the open source way, right? more usages, more stable and robust the model will be.
* Star it! :) - if you'r happy with it and find it useful.
* Code, if you are a coder and would like to contribute code then visit the Development page.

#License

See _LICENSE_ file.
