import 'ast.dart';
import 'functions.dart';

class Interpreter implements Visitor<dynamic> {
  final Map<String, dynamic> variables;
  final Functions functions;

  Interpreter({Map<String, dynamic>? variables, Functions? functions})
    : variables = variables ?? {},
      functions = functions ?? StandardFunctions();

  dynamic evaluate(Expression expr) {
    return expr.accept(this);
  }

  @override
  dynamic visitLiteral(Literal expr) {
    if (expr.type == LiteralType.bytes) {
      // In CEL, byte literals are just strings marked as bytes
      // They are not base64 encoded
      return expr.value;
    }
    return expr.value;
  }

  @override
  dynamic visitIdentifier(Identifier expr) {
    if (!variables.containsKey(expr.name)) {
      throw EvaluationError('Undefined variable: ${expr.name}');
    }
    return variables[expr.name];
  }

  @override
  dynamic visitSelect(Select expr) {
    final target = expr.operand != null ? evaluate(expr.operand!) : variables;

    if (target == null) {
      if (expr.isTest) {
        return false;
      }
      throw EvaluationError('Cannot select field ${expr.field} from null');
    }

    if (target is Map) {
      if (expr.isTest) {
        return target.containsKey(expr.field);
      }
      if (!target.containsKey(expr.field)) {
        throw EvaluationError('Field ${expr.field} not found');
      }
      return target[expr.field];
    }

    throw EvaluationError('Cannot select field from non-map type');
  }

  @override
  dynamic visitCall(Call expr) {
    // For macro calls, we need special handling
    if (expr.isMacro && expr.target != null) {
      final target = evaluate(expr.target!);

      // For macros, we pass the AST expressions, not evaluated values
      // The first argument should be an identifier (variable name)
      if (expr.args.isEmpty) {
        throw EvaluationError('Macro ${expr.function} requires arguments');
      }

      // Extract variable name from first argument
      final expression = expr.args[0];
      if (expression is! Identifier) {
        throw EvaluationError(
          'First argument to macro ${expr.function} must be a variable name',
        );
      }
      final name = expression.name;

      // Second argument is the expression (kept as AST)
      if (expr.args.length < 2) {
        throw EvaluationError(
          'Macro ${expr.function} requires an expression argument',
        );
      }
      final macro = expr.args[1];

      // Handle each macro function
      return _evaluateMacro(target, expr.function, name, macro);
    }

    // Regular function call - evaluate all arguments
    final args = expr.args.map((arg) => evaluate(arg)).toList();
    if (expr.target != null) {
      final target = evaluate(expr.target!);
      return functions.callMethod(target, expr.function, args);
    } else {
      return functions.call(expr.function, args);
    }
  }

  dynamic _evaluateMacro(
    dynamic target,
    String function,
    String name,
    Expression expr,
  ) {
    if (target is! List) {
      throw EvaluationError('Macro $function requires a list target');
    }

    // Save the current value of the variable (if any)
    final savedValue = variables.containsKey(name) ? variables[name] : null;
    final hadValue = variables.containsKey(name);

    try {
      switch (function) {
        case 'map':
          final results = [];
          for (final item in target) {
            variables[name] = item;
            results.add(evaluate(expr));
          }
          return results;

        case 'filter':
          final results = [];
          for (final item in target) {
            variables[name] = item;
            final condition = evaluate(expr);
            if (condition == true) {
              results.add(item);
            }
          }
          return results;

        case 'all':
          for (final item in target) {
            variables[name] = item;
            final condition = evaluate(expr);
            if (condition != true) {
              return false;
            }
          }
          return true;

        case 'exists':
          for (final item in target) {
            variables[name] = item;
            final condition = evaluate(expr);
            if (condition == true) {
              return true;
            }
          }
          return false;

        case 'existsOne':
          int count = 0;
          for (final item in target) {
            variables[name] = item;
            final condition = evaluate(expr);
            if (condition == true) {
              count++;
              if (count > 1) {
                return false;
              }
            }
          }
          return count == 1;

        default:
          throw EvaluationError('Unknown macro function: $function');
      }
    } finally {
      // Restore the original value of the variable
      if (hadValue) {
        variables[name] = savedValue;
      } else {
        variables.remove(name);
      }
    }
  }

  @override
  dynamic visitList(ListExpression expr) {
    return expr.elements.map((e) => evaluate(e)).toList();
  }

  @override
  dynamic visitMap(MapExpression expr) {
    final map = <dynamic, dynamic>{};
    for (final entry in expr.entries) {
      final key = evaluate(entry.key);
      final value = evaluate(entry.value);
      map[key] = value;
    }
    return map;
  }

  @override
  dynamic visitStruct(Struct expr) {
    final map = <String, dynamic>{};
    for (final field in expr.fields) {
      map[field.field] = evaluate(field.value);
    }
    return map;
  }

  @override
  dynamic visitComprehension(Comprehension expr) {
    final range = evaluate(expr.iterRange);
    if (range is! List) {
      throw EvaluationError('Comprehension range must be a list');
    }

    final savedIterator = variables[expr.iterVar];
    final savedAccumulator = variables[expr.accuVar];

    try {
      dynamic accumulator = evaluate(expr.accuInit);
      variables[expr.accuVar] = accumulator;

      for (final item in range) {
        variables[expr.iterVar] = item;

        final condition = evaluate(expr.loopCondition);
        if (condition != true) {
          continue;
        }

        accumulator = evaluate(expr.loopStep);
        variables[expr.accuVar] = accumulator;
      }

      return evaluate(expr.result);
    } finally {
      if (savedIterator != null) {
        variables[expr.iterVar] = savedIterator;
      } else {
        variables.remove(expr.iterVar);
      }
      if (savedAccumulator != null) {
        variables[expr.accuVar] = savedAccumulator;
      } else {
        variables.remove(expr.accuVar);
      }
    }
  }

  @override
  dynamic visitUnary(Unary expr) {
    final operand = evaluate(expr.operand);

    switch (expr.op) {
      case UnaryOp.not:
        if (operand is! bool) {
          throw EvaluationError('NOT operator requires boolean operand');
        }
        return !operand;
      case UnaryOp.negate:
        if (operand is num) {
          return -operand;
        }
        throw EvaluationError('Negation requires numeric operand');
    }
  }

  @override
  dynamic visitBinary(Binary expr) {
    final left = evaluate(expr.left);

    if (expr.op == BinaryOp.logicalAnd) {
      if (left != true) return false;
      return evaluate(expr.right) == true;
    } else if (expr.op == BinaryOp.logicalOr) {
      if (left == true) return true;
      return evaluate(expr.right) == true;
    }

    final right = evaluate(expr.right);

    switch (expr.op) {
      case BinaryOp.add:
        if (left is String || right is String) {
          return '$left$right';
        } else if (left is List && right is List) {
          return [...left, ...right];
        } else if (left is num && right is num) {
          return left + right;
        }
        throw EvaluationError('Invalid operands for addition');

      case BinaryOp.subtract:
        if (left is num && right is num) {
          return left - right;
        }
        throw EvaluationError('Subtraction requires numeric operands');

      case BinaryOp.multiply:
        if (left is num && right is num) {
          return left * right;
        } else if (left is String && right is int) {
          return left * right;
        } else if (left is List && right is int) {
          final result = [];
          for (int i = 0; i < right; i++) {
            result.addAll(left);
          }
          return result;
        }
        throw EvaluationError('Invalid operands for multiplication');

      case BinaryOp.divide:
        if (left is num && right is num) {
          if (right == 0) {
            throw EvaluationError('Division by zero');
          }
          return left / right;
        }
        throw EvaluationError('Division requires numeric operands');

      case BinaryOp.modulo:
        if (left is int && right is int) {
          if (right == 0) {
            throw EvaluationError('Modulo by zero');
          }
          return left % right;
        }
        throw EvaluationError('Modulo requires integer operands');

      case BinaryOp.equal:
        return _equals(left, right);

      case BinaryOp.notEqual:
        return !_equals(left, right);

      case BinaryOp.less:
        return _compare(left, right) < 0;

      case BinaryOp.lessEqual:
        return _compare(left, right) <= 0;

      case BinaryOp.greater:
        return _compare(left, right) > 0;

      case BinaryOp.greaterEqual:
        return _compare(left, right) >= 0;

      case BinaryOp.inOp:
        if (right is List) {
          return right.contains(left);
        } else if (right is Map) {
          return right.containsKey(left);
        } else if (right is String) {
          if (left is String) {
            return right.contains(left);
          }
        }
        throw EvaluationError(
          'IN operator requires list, map, or string on right side',
        );

      default:
        throw EvaluationError('Unknown binary operator: ${expr.op}');
    }
  }

  @override
  dynamic visitConditional(Conditional expr) {
    final condition = evaluate(expr.condition);
    if (condition == true) {
      return evaluate(expr.thenExpr);
    } else {
      return evaluate(expr.elseExpr);
    }
  }

  @override
  dynamic visitIndex(Index expr) {
    final operand = evaluate(expr.operand);
    final index = evaluate(expr.index);

    if (operand == null) {
      throw EvaluationError('Cannot index null value');
    }

    if (operand is List) {
      if (index is! int) {
        throw EvaluationError('List index must be an integer');
      }
      if (index < 0 || index >= operand.length) {
        throw EvaluationError('List index out of bounds: $index');
      }
      return operand[index];
    } else if (operand is Map) {
      if (!operand.containsKey(index)) {
        throw EvaluationError('Map key not found: $index');
      }
      return operand[index];
    } else if (operand is String) {
      if (index is! int) {
        throw EvaluationError('String index must be an integer');
      }
      if (index < 0 || index >= operand.length) {
        throw EvaluationError('String index out of bounds: $index');
      }
      return operand[index];
    }

    throw EvaluationError('Cannot index type: ${operand.runtimeType}');
  }

  bool _equals(dynamic left, dynamic right) {
    if (left == null || right == null) {
      return left == right;
    }

    if (left is List && right is List) {
      if (left.length != right.length) return false;
      for (int i = 0; i < left.length; i++) {
        if (!_equals(left[i], right[i])) return false;
      }
      return true;
    }

    if (left is Map && right is Map) {
      if (left.length != right.length) return false;
      for (final key in left.keys) {
        if (!right.containsKey(key)) return false;
        if (!_equals(left[key], right[key])) return false;
      }
      return true;
    }

    return left == right;
  }

  int _compare(dynamic left, dynamic right) {
    if (left == null && right == null) return 0;
    if (left == null) return -1;
    if (right == null) return 1;

    if (left is num && right is num) {
      return left.compareTo(right);
    } else if (left is String && right is String) {
      return left.compareTo(right);
    } else if (left is bool && right is bool) {
      return (left ? 1 : 0).compareTo(right ? 1 : 0);
    } else if (left is List && right is List) {
      final minLen = left.length < right.length ? left.length : right.length;
      for (int i = 0; i < minLen; i++) {
        final cmp = _compare(left[i], right[i]);
        if (cmp != 0) return cmp;
      }
      return left.length.compareTo(right.length);
    }

    throw EvaluationError(
      'Cannot compare types: ${left.runtimeType} and ${right.runtimeType}',
    );
  }
}

class EvaluationError implements Exception {
  final String message;

  EvaluationError(this.message);

  @override
  String toString() => 'EvaluationError: $message';
}
