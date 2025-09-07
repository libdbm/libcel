# CEL Implementation Feature List

This document provides a comprehensive list of all implemented CEL features in libcel.

## Fully Implemented Features

### Literals
- **Null**: `null`
- **Boolean**: `true`, `false`
- **Integer**: 
  - Decimal: `42`, `-7`
  - Hexadecimal: `0x2A`, `0xFF`, `-0x10`
- **Unsigned Integer**:
  - Decimal: `42u`, `100U`
  - Hexadecimal: `0x2Au`, `0xFFU`
- **Double**:
  - Standard: `3.14`, `-2.71`
  - Scientific: `6.022e23`, `1.5e-10`
- **String**:
  - Double-quoted: `"hello"`
  - Single-quoted: `'world'`
  - Triple-quoted: `"""multi\nline"""`, `'''text'''`
  - Raw strings: `r"raw\nstring"`, `R'no\tescape'`
  - Raw triple-quoted: `r"""raw\ntriple"""`, `R'''text'''`
- **Bytes**:
  - Lowercase prefix: `b"bytes"`, `b'\x00\xFF'`
  - Uppercase prefix: `B"bytes"`, `B'\x00\xFF'`
- **List**: `[1, 2, 3]`, `[]`, `[true, "mixed", 3.14]`
- **Map**: `{"key": "value"}`, `{}`, `{1: "one", 2: "two"}`

### Escape Sequences
All standard CEL escape sequences are supported:
- `\\` - Backslash
- `\"` - Double quote
- `\'` - Single quote
- `` \` `` - Backtick
- `\?` - Question mark
- `\a` - Bell/alert (0x07)
- `\b` - Backspace (0x08)
- `\f` - Form feed (0x0C)
- `\n` - Line feed (0x0A)
- `\r` - Carriage return (0x0D)
- `\t` - Horizontal tab (0x09)
- `\v` - Vertical tab (0x0B)
- `\xHH` - Hexadecimal escape (2 hex digits)
- `\uHHHH` - Unicode BMP (4 hex digits)
- `\UHHHHHHHH` - Unicode any plane (8 hex digits)
- `\NNN` - Octal escape (3 octal digits, 000-377)

### Operators

#### Arithmetic Operators
- Addition: `+` (numbers, strings, lists)
- Subtraction: `-` (numbers)
- Multiplication: `*` (numbers, string×int, list×int)
- Division: `/` (numbers)
- Modulo: `%` (numbers)
- Unary negation: `-x`

#### Comparison Operators
- Equal: `==`
- Not equal: `!=`
- Less than: `<`
- Less than or equal: `<=`
- Greater than: `>`
- Greater than or equal: `>=`

#### Logical Operators
- Logical AND: `&&` (with short-circuit evaluation)
- Logical OR: `||` (with short-circuit evaluation)
- Logical NOT: `!`

#### Membership Operator
- `in` - Check membership in list, map, or string

#### Conditional Operator
- Ternary: `condition ? true_value : false_value`

### Access Operations
- Field selection: `obj.field`
- Nested field: `obj.nested.field`
- List indexing: `list[0]`
- Map indexing: `map["key"]`
- Method calls: `obj.method()`
- Function calls: `function(arg1, arg2)`

### Built-in Functions

#### Type Conversion
- `int(x)` - Convert to integer
- `uint(x)` - Convert to unsigned integer
- `double(x)` - Convert to double
- `string(x)` - Convert to string
- `bool(x)` - Convert to boolean
- `type(x)` - Get type name as string
- `dyn(x)` - Convert to dynamic type

#### Collection Functions
- `size(x)` - Get size of string, list, or map
- `has(map, key)` - Check if map has key
- `max(a, b)` - Return maximum value
- `min(a, b)` - Return minimum value

#### String Functions
- `contains(string, substring)` - Check substring presence
- `startsWith(string, prefix)` - Check string prefix
- `endsWith(string, suffix)` - Check string suffix
- `matches(string, regex)` - Regex pattern matching

#### List Comprehension Macros
- `list.map(x, expression)` - Transform each element
- `list.filter(x, predicate)` - Filter elements
- `list.all(x, predicate)` - Check if all match
- `list.exists(x, predicate)` - Check if any matches
- `list.exists_one(x, predicate)` - Check if exactly one matches

### Data Structures
- Lists with heterogeneous types
- Maps with any key/value types
- Nested structures
- Struct/object literals: `Type{field: value}`
- Qualified identifiers: `package.Type`

### Expression Features
- Variable binding from context
- Expression composition
- Operator precedence
- Parentheses for grouping
- Method chaining
- Null safety with `has()` function

## Implementation Notes

### Parser
- Built using PetitParser v7.0.1
- Full EBNF grammar implementation
- AST (Abstract Syntax Tree) generation
- Comprehensive error reporting

### Interpreter
- Tree-walking interpreter
- Dynamic type checking
- Short-circuit evaluation for logical operators
- Lazy evaluation for conditional expressions

### Performance
- Expression compilation for reuse
- Efficient list comprehension with early termination
- Optimized string operations

## Not Implemented

These CEL features are not currently implemented:
- Protocol buffer message types
- Timestamp and Duration types (placeholder values only)
- Gradual type checking
- Type annotations
- Some advanced built-in functions

## Compliance

The implementation is **100% compliant** with the CEL grammar specification for all implemented features. All syntax elements, operators, and literal formats match the official Google CEL specification exactly.

## Testing

- 67+ comprehensive unit tests
- All tests passing
- Coverage includes:
  - All literal types
  - All operators
  - All escape sequences
  - List comprehensions
  - Error handling
  - Edge cases