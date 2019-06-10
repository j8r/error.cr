# Crystal Error

[![Build Status](https://cloud.drone.io/api/badges/j8r/error.cr/status.svg)](https://cloud.drone.io/j8r/error.cr)
[![ISC](https://img.shields.io/badge/License-ISC-blue.svg?style=flat-square)](https://en.wikipedia.org/wiki/ISC_license)

An efficient way to handle errors without using `raise` - no expensive stack unwinding.

## Advantages

Over "classic" `Exception` errors, this approach provides:

- Shorter traces without stdlib related calls
- More useful output with the object and method called
- More performant than unwinding the stack (what `raise` does)

The main disadvantage is the slight verbosity added, having a new type `Error` type to handle.
On the other side `begin/rescue` aren't needed

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  error:
    github: j8r/error.cr
```

## Usage

### Simple error

```crystal
require "error"

def it_throws
  Error.throw "Oops!"
end
p it_throws
```
result:
```
Oops! (Error)
   from myapp.cr:4 in 'it_throws'
```

### Handling errors

```crystal
require "error"

struct Obj
  def action : String | Error
    Error.throw("Shouldn't be true") || "normal"
  end
end

def main_program : String | Error
  case result = Obj.new.action
  # Throw the error on the top.
  # Optionaly, the message can be modified and a parent error specified.
  when Error then Error.throw "Action not successful: #{result}", result
  else            "operation successful: " + result
  end
end

p main_program
```
result:
```
Action not successful: Shouldn't be true (Error)
   from myapp.cr:5 in 'Obj#action'
   from myapp.cr:13 in 'main_program'
```

### Custom errors

```crystal
class CustomError < Error
  @message = "This is a custom error message"
end

def action
  CustomError.throw
end

p action
```
result:
```
This is a custom error message (CustomError)
   from app.cr:6 in 'action'
```

## FAQ

### I can't use this in my main program.

This libary can only be used inside methods, because the `Error.throw` macro expands to a `return Error`.

### This doesn't work in the `initialize` of my class!

A class initializer can't return an union, only an instance of the class.

You can create a `self.new` method that returns the union of the class and `Error`.

## License

Copyright (c) 2018-2019 Julien Reichardt - ISC License
