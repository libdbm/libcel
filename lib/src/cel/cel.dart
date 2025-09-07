import 'package:petitparser/petitparser.dart' show Failure;

import 'ast.dart';
import 'parser.dart';
import 'interpreter.dart';
import 'functions.dart';

export 'interpreter.dart' show EvaluationError;

/// The main entry point for evaluating CEL expressions.
///
/// The [Cel] class provides methods to compile and evaluate CEL expressions.
/// It supports all standard CEL operators, functions, and macros.
///
/// Example:
/// ```dart
/// final cel = Cel();
/// final result = cel.eval('x * 2 + y', {'x': 10, 'y': 5});
/// print(result); // 25
/// ```
class Cel {
  /// Optional custom function library.
  /// If not provided, [StandardFunctions] will be used.
  final Functions? functions;

  /// Creates a new CEL evaluator.
  ///
  /// [functions] - Optional custom function library. If not provided,
  /// the standard CEL function library will be used.
  Cel({this.functions});

  /// Compiles a CEL expression into a reusable program.
  ///
  /// This method parses the expression and returns a [CelProgram] that can
  /// be evaluated multiple times with different variables. This is more
  /// efficient than calling [eval] repeatedly with the same expression.
  ///
  /// Throws [ParseError] if the expression is invalid.
  ///
  /// Example:
  /// ```dart
  /// final program = cel.compile('price * quantity');
  /// final result1 = program.evaluate({'price': 10, 'quantity': 5});
  /// final result2 = program.evaluate({'price': 20, 'quantity': 3});
  /// ```
  CelProgram compile(String expression) {
    final parser = CelParser();
    final result = parser.parse(expression);

    if (result is Failure) {
      throw ParseError(
        'Failed to parse CEL expression at position ${result.position}: ${result.message}',
      );
    }

    final expr = result.value;
    if (expr is! Expression) {
      throw ParseError(
        'Failed to parse CEL expression: invalid expression structure',
      );
    }

    return CelProgram(expr, functions: functions);
  }

  /// Evaluates a CEL expression with the given variables.
  ///
  /// This is a convenience method that compiles and evaluates the expression
  /// in one step. For better performance when evaluating the same expression
  /// multiple times, use [compile] to create a reusable [CelProgram].
  ///
  /// [expression] - The CEL expression to evaluate.
  /// [variables] - A map of variable names to their values.
  ///
  /// Returns the result of evaluating the expression.
  ///
  /// Throws [ParseError] if the expression is invalid.
  /// Throws [EvaluationError] if an error occurs during evaluation.
  ///
  /// Example:
  /// ```dart
  /// final result = cel.eval('user.age >= 18', {
  ///   'user': {'name': 'Alice', 'age': 25}
  /// });
  /// ```
  dynamic eval(String expression, Map<String, dynamic> variables) {
    final program = compile(expression);
    return program.evaluate(variables);
  }
}

/// A compiled CEL program that can be evaluated multiple times.
///
/// A [CelProgram] represents a parsed CEL expression that can be efficiently
/// evaluated with different sets of variables. This is more efficient than
/// parsing the expression each time it needs to be evaluated.
///
/// Programs are created using [Cel.compile] and should be reused when the
/// same expression needs to be evaluated multiple times.
class CelProgram {
  /// The abstract syntax tree of the compiled expression.
  final Expression ast;
  
  /// Optional custom function library.
  final Functions? functions;

  /// Creates a new compiled program.
  ///
  /// This constructor is typically called by [Cel.compile] and should not
  /// be used directly.
  CelProgram(this.ast, {this.functions});

  /// Evaluates the compiled program with the given variables.
  ///
  /// [variables] - A map of variable names to their values.
  ///
  /// Returns the result of evaluating the expression.
  ///
  /// Throws [EvaluationError] if an error occurs during evaluation,
  /// such as undefined variables or type mismatches.
  ///
  /// Example:
  /// ```dart
  /// final result = program.evaluate({
  ///   'x': 10,
  ///   'y': 20,
  ///   'items': [1, 2, 3]
  /// });
  /// ```
  dynamic evaluate(Map<String, dynamic> variables) {
    final interpreter = Interpreter(
      variables: Map<String, dynamic>.from(variables),
      functions: functions ?? StandardFunctions(),
    );
    return interpreter.evaluate(ast);
  }
}

/// Exception thrown when a CEL expression cannot be parsed.
///
/// This exception indicates a syntax error in the CEL expression,
/// such as unmatched parentheses, invalid operators, or malformed literals.
class ParseError implements Exception {
  /// The error message describing what went wrong.
  final String message;

  /// Creates a new parse error with the given message.
  ParseError(this.message);

  @override
  String toString() => 'ParseError: $message';
}
