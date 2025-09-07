# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-09-06

### Initial Checkin
- Initial release of libcel - A Dart implementation of the Common Expression Language (CEL)
- Complete CEL expression parser using PetitParser v7.0.1
- Full support for all CEL operators:
  - Arithmetic: `+`, `-`, `*`, `/`, `%`
  - Comparison: `==`, `!=`, `<`, `<=`, `>`, `>=`, `in`
  - Logical: `&&`, `||`, `!`
  - Conditional: `? :`
- Comprehensive built-in function library:
  - Type conversion: `int()`, `double()`, `string()`, `bool()`, `type()`
  - Collection functions: `size()`, `has()`, `keys()`, `values()`
  - String functions: `matches()`, `contains()`, `startsWith()`, `endsWith()`, `toLowerCase()`, `toUpperCase()`, `trim()`, `replace()`, `split()`
  - Math functions: `max()`, `min()`
  - Date/time functions: `timestamp()`, `duration()`, `now()`, `today()`
- Support for complex data types:
  - Primitives (null, bool, int, double, string)
  - Lists with indexing and concatenation
  - Maps with field access and key lookup
  - Nested data structures
- Method call syntax for string and list operations
- Extensible function system for custom implementations
- Comprehensive error handling with `ParseError` and `EvaluationError`
- Full test coverage with 35+ test cases
- Complete documentation and examples
- **Macro Functions**: Full implementation of list comprehension functions
  - `list.map(var, expression)` - Transform list elements
  - `list.filter(var, condition)` - Filter by condition
  - `list.all(var, condition)` - Check if all match
  - `list.exists(var, condition)` - Check if any matches
  - `list.existsOne(var, condition)` - Check if exactly one matches
  - Support for nested macros and chaining
  - Proper variable scoping and restoration

### Known Limitations
- Protocol buffer support not yet available
- Some advanced CEL features pending implementation
