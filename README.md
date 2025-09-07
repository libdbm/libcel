# libcel

A complete Dart implementation of the Common Expression Language (CEL) specification.

## Overview

libcel is a powerful expression evaluation library that implements Google's Common Expression Language (CEL) specification. CEL is a non-Turing complete language designed for simplicity, speed, and safety. It's commonly used for evaluating user-provided expressions in a secure sandbox.

### Key Features

- **CEL Compatibility**: Implements a substantial portion of the CEL specification
- **Type Safety**: Strong type checking with Dart's type system
- **High Performance**: Efficient parsing and evaluation with AST compilation
- **Extensible**: Easy to add custom functions
- **Well Tested**: Comprehensive test suite including official CEL conformance tests
- **Pure Dart**: No external dependencies except PetitParser for parsing

## Installation

Add libcel to your `pubspec.yaml`:

```yaml
dependencies:
  libcel: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:libcel/libcel.dart';

void main() {
  final cel = Cel();
  
  // Simple expression evaluation
  print(cel.eval('2 + 3 * 4', {})); // Output: 14
  
  // Using variables
  final vars = {'name': 'Alice', 'age': 30};
  print(cel.eval('name + " is " + string(age) + " years old"', vars)); 
  // Output: Alice is 30 years old
  
  // Boolean logic
  print(cel.eval('age >= 18 && age < 65', vars)); // Output: true
}
```

## API Reference

### Core Classes

#### `Cel`

The main entry point for evaluating CEL expressions.

```dart
// Create a CEL evaluator with default functions
final cel = Cel();

// Create with custom functions
final cel = Cel(functions: MyCustomFunctions());
```

**Methods:**

- `eval(String expression, Map<String, dynamic> variables)` - Evaluate an expression with variables
- `compile(String expression)` - Compile an expression into a reusable CelProgram

#### `CelProgram`

A compiled CEL expression that can be evaluated multiple times with different variables.

```dart
// Compile once
final program = cel.compile('price * quantity * (1 - discount)');

// Evaluate many times
final result1 = program.evaluate({'price': 10, 'quantity': 5, 'discount': 0.1});
final result2 = program.evaluate({'price': 20, 'quantity': 3, 'discount': 0.2});
```

### Error Handling

Two types of exceptions can be thrown:

- `ParseError` - Thrown when an expression has syntax errors
- `EvaluationError` - Thrown during evaluation (undefined variables, type mismatches, etc.)

```dart
try {
  final result = cel.eval('x + y', {'x': 10});
} on ParseError catch (e) {
  print('Syntax error: $e');
} on EvaluationError catch (e) {
  print('Runtime error: $e'); // Undefined variable: y
}
```

## Language Features

### Supported Literals

| Type | Examples |
|------|----------|
| Null | `null` |
| Boolean | `true`, `false` |
| Integer | `42`, `-7`, `0x2A`, `0xFF` |
| Unsigned | `42u`, `0x2AU` |
| Double | `3.14`, `-2.71`, `6.022e23` |
| String | `"hello"`, `'world'`, `"line\nbreak"` |
| Triple-quoted | `"""multi<br>line"""`, `'''text'''` |
| Raw String | `r"raw\nstring"`, `R'no\tescape'` |
| Bytes | `b"bytes"`, `B'\x00\xff'` |
| List | `[1, 2, 3]`, `["a", "b"]`, `[]` |
| Map | `{"a": 1, "b": 2}`, `{}` |

### Escape Sequences

Strings and bytes support the following escape sequences:
- `\\` - Backslash
- `\"` - Double quote
- `\'` - Single quote
- `` \` `` - Backtick
- `\?` - Question mark
- `\a` - Bell/alert
- `\b` - Backspace
- `\f` - Form feed
- `\n` - Line feed
- `\r` - Carriage return
- `\t` - Tab
- `\v` - Vertical tab
- `\xHH` - Hex escape (2 digits)
- `\uHHHH` - Unicode (4 digits)
- `\UHHHHHHHH` - Unicode (8 digits)
- `\NNN` - Octal escape (3 digits, 000-377)

### Operators

#### Arithmetic
- Addition: `+` (numbers, strings, lists)
- Subtraction: `-`
- Multiplication: `*`
- Division: `/`
- Modulo: `%`
- Negation: `-x`

#### Comparison
- Equal: `==`
- Not Equal: `!=`
- Less Than: `<`
- Less or Equal: `<=`
- Greater Than: `>`
- Greater or Equal: `>=`

#### Logical
- AND: `&&`
- OR: `||`
- NOT: `!`

#### Membership
- IN: `in` (for lists, maps, strings)

#### Conditional
- Ternary: `condition ? true_value : false_value`

### Access Operations

```dart
// List indexing
cel.eval('[1, 2, 3][1]', {})  // 2

// Map indexing
cel.eval('{"a": 1}["a"]', {})  // 1

// Field selection
cel.eval('{"name": "Alice"}.name', {})  // "Alice"

// Nested access
cel.eval('users[0].address.city', {
  'users': [
    {'address': {'city': 'Seattle'}}
  ]
})  // "Seattle"

// Safe navigation with has()
cel.eval('has(user.address, "city")', {
  'user': {'address': {'city': 'Seattle'}}
})  // true
```

## Built-in Functions

### Type Conversions
- `int(x)` - Convert to integer
- `double(x)` - Convert to double
- `string(x)` - Convert to string
- `bool(x)` - Convert to boolean
- `type(x)` - Get type name as string

### Collections
- `size(x)` - Get size of string, list, or map
- `has(map, key)` - Check if map has key

### String Functions
- `x.contains(y)` - Check if string contains substring
- `x.startsWith(y)` - Check if string starts with prefix
- `x.endsWith(y)` - Check if string ends with suffix
- `matches(string, regex)` - Check if string matches regex pattern

### List Comprehensions (Macros)

libcel supports all CEL macro functions for list processing:

```dart
// map - Transform each element
cel.eval('[1, 2, 3].map(x, x * 2)', {})  // [2, 4, 6]

// filter - Keep elements matching condition
cel.eval('[1, 2, 3, 4].filter(x, x % 2 == 0)', {})  // [2, 4]

// exists - Check if any element matches
cel.eval('[1, 2, 3].exists(x, x > 2)', {})  // true

// all - Check if all elements match
cel.eval('[1, 2, 3].all(x, x > 0)', {})  // true

// exists_one - Check if exactly one element matches
cel.eval('[1, 2, 3].exists_one(x, x == 2)', {})  // true
```

## Extending with Custom Functions

You can add custom functions by extending `StandardFunctions`:

```dart
class MyFunctions extends StandardFunctions {
  @override
  dynamic call(String name, List<dynamic> args) {
    switch (name) {
      case 'reverse':
        return (args[0] as String).split('').reversed.join('');
      case 'sqrt':
        return math.sqrt(args[0] as num);
      default:
        return super.call(name, args);
    }
  }
}

// Use custom functions
final cel = Cel(functions: MyFunctions());
print(cel.eval('reverse("hello")', {}));  // "olleh"
print(cel.eval('sqrt(16)', {}));  // 4.0
```

## Advanced Usage

### Performance Optimization

For expressions that will be evaluated multiple times, compile them once:

```dart
// Inefficient - parses expression every time
for (final item in items) {
  final result = cel.eval('price * quantity > 100', item);
  // ...
}

// Efficient - parse once, evaluate many times
final program = cel.compile('price * quantity > 100');
for (final item in items) {
  final result = program.evaluate(item);
  // ...
}
```

### Complex Data Structures

CEL works seamlessly with nested Dart data structures:

```dart
final data = {
  'user': {
    'name': 'Alice',
    'roles': ['admin', 'user'],
    'metadata': {
      'created': '2024-01-01',
      'active': true
    }
  },
  'permissions': ['read', 'write', 'delete']
};

// Check complex conditions
final canDelete = cel.eval(
  '"admin" in user.roles && "delete" in permissions',
  data
);  // true

// Transform data
final summary = cel.eval(
  'user.name + " (" + string(user.roles.size()) + " roles)"',
  data
);  // "Alice (2 roles)"
```

## Current Implementation Status

### Fully Implemented
- All CEL operators (arithmetic, comparison, logical)
- All literal types (null, bool, int, uint, double, string, bytes, list, map)
- Hexadecimal integer literals (`0x2A`)
- Triple-quoted strings for multiline text
- Raw strings (no escape processing)
- All escape sequences including octal
- Variable binding and evaluation
- Field selection and indexing
- Function calls (built-in and custom)
- List comprehension macros (map, filter, all, exists, exists_one)
- Type conversions
- String operations
- Conditional expressions (ternary operator)

### Limitations
- No support for proto message types (Dart-specific implementation)
- Date/time functions return placeholder values (timestamp, duration)
- Some advanced CEL features like gradual type checking are simplified

## Testing

The library includes comprehensive tests:

```bash
# Run all tests
dart test

# Run with coverage
dart test --coverage=coverage

# Run specific test file
dart test test/cel_conformance_test.dart
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Make sure to:

1. Add tests for new features
2. Ensure all tests pass
3. Follow Dart formatting conventions (`dart format`)
4. Update documentation as needed

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Based on the [Common Expression Language](https://github.com/google/cel-spec) specification by Google
- Uses [PetitParser](https://pub.dev/packages/petitparser) for parsing

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/libdbm/libcel).