/// A Dart implementation of the Common Expression Language (CEL).
///
/// CEL is a simple, fast, and extensible expression language designed for
/// evaluating expressions in constrained environments. This library provides
/// a complete implementation with support for all CEL operators, built-in
/// functions, and the ability to extend with custom functions.
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:libcel/libcel.dart';
///
/// void main() {
///   final cel = Cel();
///
///   // Evaluate simple expressions
///   print(cel.eval('2 + 3 * 4', {})); // 14
///
///   // Use variables
///   final vars = {'x': 10, 'y': 20};
///   print(cel.eval('x + y', vars)); // 30
///
///   // Work with complex data
///   final data = {
///     'user': {'name': 'Alice', 'age': 30},
///     'items': [1, 2, 3]
///   };
///   print(cel.eval('user.age > 25 && size(items) > 2', data)); // true
/// }
/// ```
///
/// ## Advanced Usage
///
/// For better performance when evaluating the same expression multiple times,
/// compile it once and reuse the compiled program:
///
/// ```dart
/// final program = cel.compile('price * quantity * (1 - discount)');
///
/// // Reuse with different variables
/// final result1 = program.evaluate({'price': 10, 'quantity': 5, 'discount': 0.1});
/// final result2 = program.evaluate({'price': 20, 'quantity': 3, 'discount': 0.2});
/// ```
///
/// ## Custom Functions
///
/// Extend the function library with custom implementations:
///
/// ```dart
/// class CustomFunctions extends StandardFunctions {
///   @override
///   dynamic call(String name, List<dynamic> args) {
///     if (name == 'myFunction') {
///       return args[0] * 2;
///     }
///     return super.call(name, args);
///   }
/// }
///
/// final cel = Cel(functions: CustomFunctions());
/// ```
library;

// Export the main CEL API
export 'src/cel/cel.dart' show Cel, CelProgram, ParseError;

// Export the interpreter error class
export 'src/cel/interpreter.dart' show EvaluationError;

// Export function interfaces for custom implementations
export 'src/cel/functions.dart' show Functions, StandardFunctions;
