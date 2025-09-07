import 'package:libcel/libcel.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print(
      'Usage: cel <expression> [variable1=value1] [variable2=value2] ...',
    );
    print('Example: cel "x + y" x=10 y=20');
    return;
  }

  final expression = arguments[0];
  final variables = <String, dynamic>{};

  // Parse variable assignments from command line
  for (var i = 1; i < arguments.length; i++) {
    final parts = arguments[i].split('=');
    if (parts.length == 2) {
      final key = parts[0];
      final value = parts[1];

      // Try to parse as number, otherwise use as string
      if (int.tryParse(value) != null) {
        variables[key] = int.parse(value);
      } else if (double.tryParse(value) != null) {
        variables[key] = double.parse(value);
      } else if (value == 'true') {
        variables[key] = true;
      } else if (value == 'false') {
        variables[key] = false;
      } else {
        variables[key] = value;
      }
    }
  }

  try {
    final cel = Cel();
    final result = cel.eval(expression, variables);
    print(result);
  } on ParseError catch (e) {
    print('Parse error: ${e.message}');
  } on EvaluationError catch (e) {
    print('Evaluation error: ${e.message}');
  }
}
