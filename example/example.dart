import 'package:libcel/libcel.dart';

void main() {
  final cel = Cel();

  // Basic arithmetic
  print('Basic Arithmetic:');
  print('2 + 3 * 4 = ${cel.eval('2 + 3 * 4', {})}'); // 14
  print('(2 + 3) * 4 = ${cel.eval('(2 + 3) * 4', {})}'); // 20
  print('10 / 3 = ${cel.eval('10 / 3', {})}'); // 3.333...
  print('10 % 3 = ${cel.eval('10 % 3', {})}'); // 1
  print('');

  // Variables
  print('Using Variables:');
  final vars = {'x': 10, 'y': 20, 'name': 'World'};
  print('x + y = ${cel.eval('x + y', vars)}'); // 30
  print('x * 2 + y = ${cel.eval('x * 2 + y', vars)}'); // 40
  print(
    '"Hello, " + name = ${cel.eval('"Hello, " + name', vars)}',
  ); // Hello, World
  print('');

  // Comparison and conditionals
  print('Comparisons and Conditionals:');
  final person = {'age': 25, 'hasLicense': true};
  print('age >= 18 = ${cel.eval('age >= 18', person)}'); // true
  print(
    'age >= 18 ? "adult" : "minor" = ${cel.eval('age >= 18 ? "adult" : "minor"', person)}',
  ); // adult
  print(
    'age >= 18 && hasLicense ? "can drive" : "cannot drive" = '
    '${cel.eval('age >= 18 && hasLicense ? "can drive" : "cannot drive"', person)}',
  ); // can drive
  print('');

  // Lists
  print('Working with Lists:');
  final listData = {
    'numbers': [1, 2, 3, 4, 5],
    'names': ['Alice', 'Bob', 'Charlie'],
  };
  print('numbers[0] = ${cel.eval('numbers[0]', listData)}'); // 1
  print('numbers[2] * 2 = ${cel.eval('numbers[2] * 2', listData)}'); // 6
  print('size(numbers) = ${cel.eval('size(numbers)', listData)}'); // 5
  print('3 in numbers = ${cel.eval('3 in numbers', listData)}'); // true
  print('names[1] = ${cel.eval('names[1]', listData)}'); // Bob
  print('[1, 2] + [3, 4] = ${cel.eval('[1, 2] + [3, 4]', {})}'); // [1, 2, 3, 4]
  print('');

  // Maps and field access
  print('Working with Maps:');
  final userData = {
    'user': {
      'name': 'Alice',
      'age': 30,
      'email': 'alice@example.com',
      'address': {'city': 'New York', 'country': 'USA'},
    },
  };
  print('user.name = ${cel.eval('user.name', userData)}'); // Alice
  print('user["age"] = ${cel.eval('user["age"]', userData)}'); // 30
  print(
    'user.address.city = ${cel.eval('user.address.city', userData)}',
  ); // New York
  print(
    'has(user, "email") = ${cel.eval('has(user, "email")', userData)}',
  ); // true
  print(
    'has(user, "phone") = ${cel.eval('has(user, "phone")', userData)}',
  ); // false
  print('');

  // String operations
  print('String Operations:');
  final stringData = {'text': '  Hello World  ', 'email': 'test@example.com'};
  print(
    'text.trim() = "${cel.eval('text.trim()', stringData)}"',
  ); // "Hello World"
  print(
    'text.trim().toLowerCase() = "${cel.eval('text.trim().toLowerCase()', stringData)}"',
  ); // "hello world"
  print(
    'text.trim().toUpperCase() = "${cel.eval('text.trim().toUpperCase()', stringData)}"',
  ); // "HELLO WORLD"
  print(
    '"hello".contains("ll") = ${cel.eval('"hello".contains("ll")', {})}',
  ); // true
  print(
    '"hello".startsWith("he") = ${cel.eval('"hello".startsWith("he")', {})}',
  ); // true
  print(
    '"hello".endsWith("lo") = ${cel.eval('"hello".endsWith("lo")', {})}',
  ); // true
  print(
    'matches(email, ".*@.*") = ${cel.eval('matches(email, ".*@.*")', stringData)}',
  ); // true
  print(
    '"a,b,c".split(",") = ${cel.eval('"a,b,c".split(",")', {})}',
  ); // [a, b, c]
  print(
    '"hello world".replace("world", "dart") = "${cel.eval('"hello world".replace("world", "dart")', {})}"',
  ); // "hello dart"
  print('');

  // Functions
  print('Built-in Functions:');
  print('int(3.14) = ${cel.eval('int(3.14)', {})}'); // 3
  print('double(42) = ${cel.eval('double(42)', {})}'); // 42.0
  print('string(123) = ${cel.eval('string(123)', {})}'); // "123"
  print('bool(1) = ${cel.eval('bool(1)', {})}'); // true
  print('type("hello") = ${cel.eval('type("hello")', {})}'); // string
  print('type([1,2]) = ${cel.eval('type([1,2])', {})}'); // list
  print('max(1, 5, 3, 2) = ${cel.eval('max(1, 5, 3, 2)', {})}'); // 5
  print('min(1, 5, 3, 2) = ${cel.eval('min(1, 5, 3, 2)', {})}'); // 1
  print('');

  // Macro functions (list comprehensions)
  print('Macro Functions:');
  print(
    '[1, 2, 3, 4, 5].map(x, x * 2) = ${cel.eval('[1, 2, 3, 4, 5].map(x, x * 2)', {})}',
  ); // [2, 4, 6, 8, 10]
  print(
    '[1, 2, 3, 4, 5].filter(x, x > 2) = ${cel.eval('[1, 2, 3, 4, 5].filter(x, x > 2)', {})}',
  ); // [3, 4, 5]
  print(
    '[2, 4, 6].all(x, x % 2 == 0) = ${cel.eval('[2, 4, 6].all(x, x % 2 == 0)', {})}',
  ); // true
  print(
    '[1, 2, 3].exists(x, x > 2) = ${cel.eval('[1, 2, 3].exists(x, x > 2)', {})}',
  ); // true
  print(
    '[1, 2, 3].existsOne(x, x == 2) = ${cel.eval('[1, 2, 3].existsOne(x, x == 2)', {})}',
  ); // true

  // Chained macros
  print(
    '[1, 2, 3, 4, 5].filter(x, x > 2).map(x, x * 10) = ${cel.eval('[1, 2, 3, 4, 5].filter(x, x > 2).map(x, x * 10)', {})}',
  ); // [30, 40, 50]
  print('');

  // Complex expressions
  print('Complex Expressions:');
  final orderData = {
    'items': [
      {'name': 'Widget', 'price': 10.0, 'quantity': 2},
      {'name': 'Gadget', 'price': 25.0, 'quantity': 1},
      {'name': 'Tool', 'price': 15.0, 'quantity': 3},
    ],
    'discount': 0.1,
    'shipping': 5.0,
  };

  // Calculate total for first item
  print(
    'First item total: ${cel.eval('items[0].price * items[0].quantity', orderData)}',
  ); // 20.0

  // Check if expensive order
  final isExpensive = cel.eval(
    'items[1].price > 20 && items[1].quantity > 0',
    orderData,
  );
  print('Has expensive items: $isExpensive'); // true

  // Compile once, evaluate multiple times for better performance
  print('\nCompiled Program Example:');
  final program = cel.compile('price * quantity * (1 - discount)');

  for (final item in [
    {'price': 10, 'quantity': 5, 'discount': 0.1},
    {'price': 20, 'quantity': 3, 'discount': 0.2},
    {'price': 15, 'quantity': 4, 'discount': 0.15},
  ]) {
    final result = program.evaluate(item);
    print(
      'Price: ${item['price']}, Qty: ${item['quantity']}, Discount: ${(item['discount'] as num) * 100}% = \$$result',
    );
  }

  // Error handling example
  print('\nError Handling:');
  try {
    cel.eval('x + y', {'x': 5}); // Missing variable 'y'
  } on EvaluationError catch (e) {
    print('Evaluation error: ${e.message}');
  }

  try {
    cel.compile('1 + + 2'); // Invalid syntax
  } on ParseError catch (e) {
    print('Parse error: ${e.message}');
  }

  // Custom functions example
  print('\nCustom Functions:');
  final customCel = Cel(functions: MyCustomFunctions());
  print(
    'double(5) with custom function = ${customCel.eval('double(5)', {})}',
  ); // 10
  print(
    'triple(7) with custom function = ${customCel.eval('triple(7)', {})}',
  ); // 21
}

// Example of extending with custom functions
class MyCustomFunctions extends StandardFunctions {
  @override
  dynamic call(String name, List<dynamic> args) {
    switch (name) {
      case 'double':
        if (args.length != 1) {
          throw ArgumentError('double() requires 1 argument');
        }
        return args[0] * 2;
      case 'triple':
        if (args.length != 1) {
          throw ArgumentError('triple() requires 1 argument');
        }
        return args[0] * 3;
      default:
        return super.call(name, args);
    }
  }
}
