# Coding rules

This is not a global Lua style recommendation, but a list of rules to understand and contribute to the code of this repository only.  

## General rules

* Use 4 spaces for indentation.
* No comment inside functions or methods, __no exception__.
* One function, one task.
* There is no strict limitation on function length, however, if a function is too long, it should be split into smaller functions.
* No code duplication, factorize your code.

## Naming

### General

Every name should be explicit and self-explanatory.

If a function says "check_something", but it checks and then do something if the check is false, it should be renamed to "check_something_process_failure".

Same for variables, if a variable is a boolean, it should be named "is_something" or "has_something". The only exception is `i` for iterators.


### Syntax

* Functions, variables, objects and methods should be named in lowercase with underscores between words.

``` Lua
local function my_function() end -- Valid
local function MyFunction() end -- Invalid

local my_variable = 1 -- Valid
local MyVariable = 1 -- Invalid

obj.my_method = function() end -- Valid
obj.MyMethod = function() end -- Invalid
```

* Constants should be named in uppercase with underscores between words.
``` Lua
FIXED_CONSTANT = 1 -- Valid
FixedConstant = 1 -- Invalid
```

* Private methods and variables should be named with a leading underscore.
``` Lua
local function _private_method() end -- Valid
local _private_variable = 1 -- Valid
```