import 'interpreter.dart' show EvaluationError;

/// Abstract interface for providing functions to CEL expressions.
///
/// Implement this class to provide custom functions that can be called
/// from CEL expressions. The [StandardFunctions] class provides all
/// standard CEL functions and can be extended for custom functionality.
///
/// Example:
/// ```dart
/// class MyFunctions extends StandardFunctions {
///   @override
///   dynamic call(String name, List<dynamic> args) {
///     if (name == 'customFunc') {
///       return myCustomImplementation(args);
///     }
///     return super.call(name, args);
///   }
/// }
/// ```
abstract class Functions {
  /// Calls a global function by name.
  ///
  /// [name] - The name of the function to call.
  /// [args] - The arguments to pass to the function.
  ///
  /// Returns the result of the function call.
  ///
  /// Throws an exception if the function is not found or if the arguments
  /// are invalid.
  dynamic call(String name, List<dynamic> args);
  
  /// Calls a method on a target object.
  ///
  /// [target] - The object to call the method on.
  /// [method] - The name of the method to call.
  /// [args] - The arguments to pass to the method.
  ///
  /// Returns the result of the method call.
  ///
  /// Throws an exception if the method is not found or if the arguments
  /// are invalid.
  dynamic callMethod(dynamic target, String method, List<dynamic> args);
}

/// Standard CEL function library implementation.
///
/// Provides all built-in CEL functions including:
/// - Type conversions: int(), double(), string(), bool()
/// - Type checking: type()
/// - Collection operations: size(), has()
/// - String operations: contains(), startsWith(), endsWith(), matches()
/// - Date/time: timestamp(), duration()
/// - Math operations: Math functions when called on numbers
///
/// This class can be extended to add custom functions while retaining
/// all standard CEL functionality.
class StandardFunctions implements Functions {
  @override
  dynamic call(String name, List<dynamic> args) {
    switch (name) {
      case 'size':
        return _size(args[0]);

      case 'int':
        return _toInt(args[0]);

      case 'uint':
        return _toUint(args[0]);

      case 'double':
        return _toDouble(args[0]);

      case 'string':
        return _toString(args[0]);

      case 'bool':
        return _toBool(args[0]);

      case 'type':
        return _getType(args[0]);

      case 'has':
        if (args.length != 2) {
          throw ArgumentError('has() requires 2 arguments');
        }
        return _has(args[0], args[1]);

      case 'matches':
        if (args.length != 2) {
          throw ArgumentError('matches() requires 2 arguments');
        }
        return _matches(args[0] as String, args[1] as String);

      case 'timestamp':
        return _timestamp(args.isNotEmpty ? args[0] : null);

      case 'duration':
        return _duration(args[0] as String);

      case 'getDate':
        return _getDate(args[0]);

      case 'getMonth':
        return _getMonth(args[0]);

      case 'getFullYear':
        return _getFullYear(args[0]);

      case 'getHours':
        return _getHours(args[0]);

      case 'getMinutes':
        return _getMinutes(args[0]);

      case 'getSeconds':
        return _getSeconds(args[0]);

      case 'max':
        return _max(args);

      case 'min':
        return _min(args);

      default:
        throw ArgumentError('Unknown function: $name');
    }
  }

  @override
  dynamic callMethod(dynamic target, String method, List<dynamic> args) {
    if (target == null) {
      throw ArgumentError('Cannot call method on null');
    }

    switch (method) {
      case 'contains':
        if (target is String && args.length == 1 && args[0] is String) {
          return target.contains(args[0]);
        } else if (target is List && args.length == 1) {
          return target.contains(args[0]);
        }
        throw ArgumentError('Invalid arguments for contains()');

      case 'startsWith':
        if (target is String && args.length == 1 && args[0] is String) {
          return target.startsWith(args[0]);
        }
        throw ArgumentError('startsWith() requires string target and argument');

      case 'endsWith':
        if (target is String && args.length == 1 && args[0] is String) {
          return target.endsWith(args[0]);
        }
        throw ArgumentError('endsWith() requires string target and argument');

      case 'toLowerCase':
        if (target is String && args.isEmpty) {
          return target.toLowerCase();
        }
        throw ArgumentError('toLowerCase() requires string target');

      case 'toUpperCase':
        if (target is String && args.isEmpty) {
          return target.toUpperCase();
        }
        throw ArgumentError('toUpperCase() requires string target');

      case 'trim':
        if (target is String && args.isEmpty) {
          return target.trim();
        }
        throw ArgumentError('trim() requires string target');

      case 'replace':
        if (target is String &&
            args.length == 2 &&
            args[0] is String &&
            args[1] is String) {
          return target.replaceAll(args[0], args[1]);
        }
        throw ArgumentError(
          'replace() requires string target and 2 string arguments',
        );

      case 'split':
        if (target is String && args.length == 1 && args[0] is String) {
          return target.split(args[0]);
        }
        throw ArgumentError('split() requires string target and separator');

      case 'size':
        return _size(target);

      // Macro functions are handled in the interpreter with special logic
      case 'map':
      case 'filter':
      case 'all':
      case 'exists':
      case 'existsOne':
        // These should be handled by the interpreter's macro evaluation
        // If we get here, something went wrong
        throw EvaluationError(
          'Macro function $method was not properly handled by the interpreter',
        );

      default:
        throw ArgumentError('Unknown method: $method');
    }
  }

  int _size(dynamic value) {
    if (value == null) return 0;
    if (value is String) return value.length;
    if (value is List) return value.length;
    if (value is Map) return value.length;
    throw ArgumentError('size() not supported for type: ${value.runtimeType}');
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.parse(value);
    if (value is bool) return value ? 1 : 0;
    throw ArgumentError('Cannot convert to int: $value');
  }

  int _toUint(dynamic value) {
    final intValue = _toInt(value);
    if (intValue < 0) {
      throw ArgumentError('Cannot convert negative value to uint: $value');
    }
    return intValue;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    throw ArgumentError('Cannot convert to double: $value');
  }

  String _toString(dynamic value) {
    if (value == null) return 'null';
    return value.toString();
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is double) return value != 0.0;
    if (value is String) return value.isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    if (value == null) return false;
    return true;
  }

  String _getType(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return 'bool';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is String) return 'string';
    if (value is List) return 'list';
    if (value is Map) return 'map';
    return 'unknown';
  }

  bool _has(dynamic target, dynamic field) {
    if (target is Map && field is String) {
      return target.containsKey(field);
    }
    return false;
  }

  bool _matches(String text, String pattern) {
    final regex = RegExp(pattern);
    return regex.hasMatch(text);
  }

  DateTime _timestamp(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    throw ArgumentError('Invalid timestamp value: $value');
  }

  Duration _duration(String value) {
    final regex = RegExp(r'^(\d+)([hms])$');
    final match = regex.firstMatch(value);
    if (match == null) {
      throw ArgumentError('Invalid duration format: $value');
    }

    final amount = int.parse(match.group(1)!);
    final unit = match.group(2)!;

    switch (unit) {
      case 'h':
        return Duration(hours: amount);
      case 'm':
        return Duration(minutes: amount);
      case 's':
        return Duration(seconds: amount);
      default:
        throw ArgumentError('Invalid duration unit: $unit');
    }
  }

  int _getDate(dynamic value) {
    final date = value is DateTime ? value : _timestamp(value);
    return date.day;
  }

  int _getMonth(dynamic value) {
    final date = value is DateTime ? value : _timestamp(value);
    return date.month - 1;
  }

  int _getFullYear(dynamic value) {
    final date = value is DateTime ? value : _timestamp(value);
    return date.year;
  }

  int _getHours(dynamic value) {
    final date = value is DateTime ? value : _timestamp(value);
    return date.hour;
  }

  int _getMinutes(dynamic value) {
    final date = value is DateTime ? value : _timestamp(value);
    return date.minute;
  }

  int _getSeconds(dynamic value) {
    final date = value is DateTime ? value : _timestamp(value);
    return date.second;
  }

  dynamic _max(List<dynamic> values) {
    if (values.isEmpty) {
      throw ArgumentError('max() requires at least one argument');
    }

    dynamic maxValue = values[0];
    for (int i = 1; i < values.length; i++) {
      if (_compareValues(values[i], maxValue) > 0) {
        maxValue = values[i];
      }
    }
    return maxValue;
  }

  dynamic _min(List<dynamic> values) {
    if (values.isEmpty) {
      throw ArgumentError('min() requires at least one argument');
    }

    dynamic minValue = values[0];
    for (int i = 1; i < values.length; i++) {
      if (_compareValues(values[i], minValue) < 0) {
        minValue = values[i];
      }
    }
    return minValue;
  }

  int _compareValues(dynamic a, dynamic b) {
    if (a is num && b is num) {
      return a.compareTo(b);
    }
    if (a is String && b is String) {
      return a.compareTo(b);
    }
    if (a is DateTime && b is DateTime) {
      return a.compareTo(b);
    }
    throw ArgumentError('Cannot compare values of different types');
  }
}
