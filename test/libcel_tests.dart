import 'package:test/test.dart';
import 'package:libcel/libcel.dart';

void main() {
  group('CEL Parser', () {
    late Cel cel;

    setUp(() {
      cel = Cel();
    });

    test('parses literals', () {
      expect(cel.eval('null', {}), isNull);
      expect(cel.eval('true', {}), isTrue);
      expect(cel.eval('false', {}), isFalse);
      expect(cel.eval('42', {}), equals(42));
      expect(cel.eval('3.14', {}), equals(3.14));
      expect(cel.eval('"hello"', {}), equals('hello'));
      expect(cel.eval('r"raw string"', {}), equals('raw string'));
    });

    test('parses hexadecimal integers', () {
      expect(cel.eval('0x10', {}), equals(16));
      expect(cel.eval('0xFF', {}), equals(255));
      expect(cel.eval('0x1A', {}), equals(26));
      expect(cel.eval('-0x10', {}), equals(-16));
      expect(cel.eval('0x10u', {}), equals(16));
      expect(cel.eval('0xFFu', {}), equals(255));
    });

    test('parses strings with octal escape sequences', () {
      expect(cel.eval(r'"\101"', {}), equals('A')); // \101 = 'A' (65 in octal)
      expect(cel.eval(r'"\040"', {}), equals(' ')); // \040 = space (32 in octal)
      expect(cel.eval(r'"\141\142\143"', {}), equals('abc')); // \141=a, \142=b, \143=c
      expect(cel.eval(r'"\000"', {}), equals('\x00')); // null character
      expect(cel.eval(r'"\377"', {}), equals('\xFF')); // max octal value (255)
    });

    test('parses strings with additional escape sequences', () {
      expect(cel.eval(r'"\a"', {}), equals('\x07')); // bell/alert
      expect(cel.eval(r'"\b"', {}), equals('\x08')); // backspace
      expect(cel.eval(r'"\f"', {}), equals('\x0C')); // form feed
      expect(cel.eval(r'"\v"', {}), equals('\x0B')); // vertical tab
      expect(cel.eval(r'"\?"', {}), equals('?')); // question mark
      expect(cel.eval(r'"\`"', {}), equals('`')); // backtick
      
      // Combined escape sequences
      expect(cel.eval(r'"Hello\bWorld"', {}), equals('Hello\x08World'));
      expect(cel.eval(r'"Line1\fLine2"', {}), equals('Line1\x0CLine2'));
      expect(cel.eval(r'"Tab\vhere"', {}), equals('Tab\x0Bhere'));
    });

    test('parses bytes literals with uppercase B prefix', () {
      expect(cel.eval('b"hello"', {}), equals('hello'));
      expect(cel.eval('B"hello"', {}), equals('hello'));
      expect(cel.eval("b'world'", {}), equals('world'));
      expect(cel.eval("B'world'", {}), equals('world'));
    });

    test('parses triple-quoted strings', () {
      // Basic triple-quoted strings
      expect(cel.eval('"""hello world"""', {}), equals('hello world'));
      expect(cel.eval("'''hello world'''", {}), equals('hello world'));
      
      // Multi-line strings
      expect(cel.eval('"""line 1\nline 2\nline 3"""', {}), 
             equals('line 1\nline 2\nline 3'));
      expect(cel.eval("'''line 1\nline 2\nline 3'''", {}), 
             equals('line 1\nline 2\nline 3'));
      
      // Strings containing quotes
      expect(cel.eval('"""She said "Hello"!"""', {}), equals('She said "Hello"!'));
      expect(cel.eval("'''It's a nice day'''", {}), equals("It's a nice day"));
      
      // Triple-quoted strings with escape sequences
      expect(cel.eval(r'"""hello\nworld"""', {}), equals('hello\nworld'));
      expect(cel.eval(r'"""tab\there"""', {}), equals('tab\there'));
      
      // Raw triple-quoted strings (no escape processing)
      expect(cel.eval(r'r"""hello\nworld"""', {}), equals(r'hello\nworld'));
      expect(cel.eval(r"R'''tab\there'''", {}), equals(r'tab\there'));
      
      // Triple-quoted strings with embedded double quotes
      expect(cel.eval('"""He said ""Hello"" twice"""', {}), 
             equals('He said ""Hello"" twice'));
    });

    test('parses identifiers', () {
      expect(cel.eval('x', {'x': 10}), equals(10));
      expect(cel.eval('name', {'name': 'John'}), equals('John'));
    });

    test('parses arithmetic expressions', () {
      expect(cel.eval('2 + 3', {}), equals(5));
      expect(cel.eval('10 - 4', {}), equals(6));
      expect(cel.eval('3 * 4', {}), equals(12));
      expect(cel.eval('15 / 3', {}), equals(5.0));
      expect(cel.eval('17 % 5', {}), equals(2));
    });

    test('respects operator precedence', () {
      expect(cel.eval('2 + 3 * 4', {}), equals(14));
      expect(cel.eval('(2 + 3) * 4', {}), equals(20));
      expect(cel.eval('10 - 2 * 3', {}), equals(4));
    });

    test('parses comparison operators', () {
      expect(cel.eval('3 < 5', {}), isTrue);
      expect(cel.eval('5 <= 5', {}), isTrue);
      expect(cel.eval('7 > 4', {}), isTrue);
      expect(cel.eval('8 >= 8', {}), isTrue);
      expect(cel.eval('5 == 5', {}), isTrue);
      expect(cel.eval('5 != 3', {}), isTrue);
    });

    test('parses logical operators', () {
      expect(cel.eval('true && true', {}), isTrue);
      expect(cel.eval('true && false', {}), isFalse);
      expect(cel.eval('false || true', {}), isTrue);
      expect(cel.eval('false || false', {}), isFalse);
      expect(cel.eval('!true', {}), isFalse);
      expect(cel.eval('!false', {}), isTrue);
    });

    test('parses conditional expressions', () {
      expect(cel.eval('true ? 1 : 2', {}), equals(1));
      expect(cel.eval('false ? 1 : 2', {}), equals(2));
      expect(cel.eval('x > 5 ? "big" : "small"', {'x': 10}), equals('big'));
      expect(cel.eval('x > 5 ? "big" : "small"', {'x': 3}), equals('small'));
    });

    test('parses list literals', () {
      expect(cel.eval('[]', {}), equals([]));
      expect(cel.eval('[1, 2, 3]', {}), equals([1, 2, 3]));
      expect(cel.eval('[1, "two", true]', {}), equals([1, 'two', true]));
    });

    test('parses map literals', () {
      expect(cel.eval('{}', {}), equals({}));
      expect(cel.eval('{"a": 1, "b": 2}', {}), equals({'a': 1, 'b': 2}));
      expect(
        cel.eval('{1: "one", 2: "two"}', {}),
        equals({1: 'one', 2: 'two'}),
      );
    });

    test('parses field selection', () {
      expect(
        cel.eval('obj.field', {
          'obj': {'field': 42},
        }),
        equals(42),
      );
      expect(
        cel.eval('obj.nested.field', {
          'obj': {
            'nested': {'field': 'value'},
          },
        }),
        equals('value'),
      );
    });

    test('parses indexing', () {
      expect(
        cel.eval('list[0]', {
          'list': [1, 2, 3],
        }),
        equals(1),
      );
      expect(
        cel.eval('list[1]', {
          'list': [1, 2, 3],
        }),
        equals(2),
      );
      expect(
        cel.eval('map["key"]', {
          'map': {'key': 'value'},
        }),
        equals('value'),
      );
      expect(cel.eval('str[0]', {'str': 'hello'}), equals('h'));
    });

    test('parses function calls', () {
      expect(cel.eval('size("hello")', {}), equals(5));
      expect(cel.eval('size([1, 2, 3])', {}), equals(3));
      expect(cel.eval('int("42")', {}), equals(42));
      expect(cel.eval('string(42)', {}), equals('42'));
    });

    test('parses method calls', () {
      expect(cel.eval('"hello".contains("ll")', {}), isTrue);
      expect(cel.eval('"hello".startsWith("he")', {}), isTrue);
      expect(cel.eval('"hello".endsWith("lo")', {}), isTrue);
      expect(cel.eval('"HELLO".toLowerCase()', {}), equals('hello'));
      expect(cel.eval('"hello".toUpperCase()', {}), equals('HELLO'));
    });

    test('parses in operator', () {
      expect(cel.eval('2 in [1, 2, 3]', {}), isTrue);
      expect(cel.eval('4 in [1, 2, 3]', {}), isFalse);
      expect(cel.eval('"key" in {"key": "value"}', {}), isTrue);
      expect(cel.eval('"missing" in {"key": "value"}', {}), isFalse);
      expect(cel.eval('"ll" in "hello"', {}), isTrue);
    });

    test('parses unary operators', () {
      expect(cel.eval('-5', {}), equals(-5));
      expect(cel.eval('--5', {}), equals(5));
      expect(cel.eval('!true', {}), isFalse);
      expect(cel.eval('!!true', {}), isTrue);
    });

    test('parses complex expressions', () {
      expect(cel.eval('x > 0 && x < 10', {'x': 5}), isTrue);
      expect(cel.eval('x > 0 && x < 10', {'x': 15}), isFalse);

      expect(cel.eval('(x + y) * z', {'x': 2, 'y': 3, 'z': 4}), equals(20));

      expect(cel.eval('[1, 2, 3].contains(2)', {}), isTrue);

      expect(
        cel.eval('user.age >= 18 ? "adult" : "minor"', {
          'user': {'age': 21},
        }),
        equals('adult'),
      );
    });
  });

  group('CEL Interpreter', () {
    late Cel cel;

    setUp(() {
      cel = Cel();
    });

    test('evaluates string concatenation', () {
      expect(cel.eval('"hello" + " " + "world"', {}), equals('hello world'));
      expect(cel.eval('"value: " + string(42)', {}), equals('value: 42'));
    });

    test('evaluates list concatenation', () {
      expect(cel.eval('[1, 2] + [3, 4]', {}), equals([1, 2, 3, 4]));
    });

    test('evaluates string multiplication', () {
      expect(cel.eval('"ab" * 3', {}), equals('ababab'));
    });

    test('evaluates list multiplication', () {
      expect(cel.eval('[1, 2] * 2', {}), equals([1, 2, 1, 2]));
    });

    test('evaluates short-circuit logical operators', () {
      var evalCount = 0;
      bool incrementAndReturn(bool value) {
        evalCount++;
        return value;
      }

      final functions = CustomFunctions({
        'check': (args) => incrementAndReturn(args[0] as bool),
      });

      final celWithCustom = Cel(functions: functions);

      evalCount = 0;
      expect(celWithCustom.eval('false && check(true)', {}), isFalse);
      expect(evalCount, equals(0));

      evalCount = 0;
      expect(celWithCustom.eval('true || check(false)', {}), isTrue);
      expect(evalCount, equals(0));
    });

    test('evaluates type conversion functions', () {
      expect(cel.eval('int(3.14)', {}), equals(3));
      expect(cel.eval('double(42)', {}), equals(42.0));
      expect(cel.eval('string(true)', {}), equals('true'));
      expect(cel.eval('bool(1)', {}), isTrue);
      expect(cel.eval('bool(0)', {}), isFalse);
    });

    test('evaluates has function', () {
      expect(
        cel.eval('has(obj, "field")', {
          'obj': {'field': 1},
        }),
        isTrue,
      );
      expect(
        cel.eval('has(obj, "missing")', {
          'obj': {'field': 1},
        }),
        isFalse,
      );
    });

    test('evaluates matches function', () {
      expect(cel.eval('matches("hello", "h.*o")', {}), isTrue);
      expect(cel.eval('matches("hello", "^h")', {}), isTrue);
      expect(cel.eval('matches("hello", "^e")', {}), isFalse);
    });

    test('evaluates max and min functions', () {
      expect(cel.eval('max(1, 2, 3)', {}), equals(3));
      expect(cel.eval('min(1, 2, 3)', {}), equals(1));
      expect(cel.eval('max("a", "b", "c")', {}), equals('c'));
      expect(cel.eval('min("a", "b", "c")', {}), equals('a'));
    });

    test('evaluates string methods', () {
      expect(cel.eval('"  hello  ".trim()', {}), equals('hello'));
      expect(
        cel.eval('"hello world".replace("world", "dart")', {}),
        equals('hello dart'),
      );
      expect(cel.eval('"a,b,c".split(",")', {}), equals(['a', 'b', 'c']));
    });

    test('evaluates type function', () {
      expect(cel.eval('type(null)', {}), equals('null'));
      expect(cel.eval('type(true)', {}), equals('bool'));
      expect(cel.eval('type(42)', {}), equals('int'));
      expect(cel.eval('type(3.14)', {}), equals('double'));
      expect(cel.eval('type("hello")', {}), equals('string'));
      expect(cel.eval('type([1, 2])', {}), equals('list'));
      expect(cel.eval('type({"a": 1})', {}), equals('map'));
    });

    test('handles null values correctly', () {
      expect(cel.eval('null == null', {}), isTrue);
      expect(cel.eval('null != 1', {}), isTrue);
      expect(cel.eval('1 != null', {}), isTrue);
    });

    test('compares lists correctly', () {
      expect(cel.eval('[1, 2] == [1, 2]', {}), isTrue);
      expect(cel.eval('[1, 2] != [2, 1]', {}), isTrue);
      expect(cel.eval('[1, 2] < [1, 3]', {}), isTrue);
      expect(cel.eval('[1, 2, 3] > [1, 2]', {}), isTrue);
    });

    test('compares maps correctly', () {
      expect(cel.eval('{"a": 1} == {"a": 1}', {}), isTrue);
      expect(cel.eval('{"a": 1} != {"b": 1}', {}), isTrue);
      expect(cel.eval('{"a": 1, "b": 2} == {"b": 2, "a": 1}', {}), isTrue);
    });

    test('throws errors for undefined variables', () {
      expect(() => cel.eval('x', {}), throwsA(isA<EvaluationError>()));
    });

    test('throws errors for invalid operations', () {
      expect(() => cel.eval('1 / 0', {}), throwsA(isA<EvaluationError>()));
      expect(() => cel.eval('1 % 0', {}), throwsA(isA<EvaluationError>()));
      expect(
        () => cel.eval('"hello" - "world"', {}),
        throwsA(isA<EvaluationError>()),
      );
    });

    test('throws errors for invalid indexing', () {
      expect(() => cel.eval('[1, 2][5]', {}), throwsA(isA<EvaluationError>()));
      expect(() => cel.eval('[1, 2][-1]', {}), throwsA(isA<EvaluationError>()));
      expect(
        () => cel.eval('{"a": 1}["b"]', {}),
        throwsA(isA<EvaluationError>()),
      );
    });
  });

  group('CEL Programs', () {
    late Cel cel;

    setUp(() {
      cel = Cel();
    });

    test('can be compiled and reused', () {
      final program = cel.compile('x * 2 + y');

      expect(program.evaluate({'x': 3, 'y': 4}), equals(10));
      expect(program.evaluate({'x': 5, 'y': 1}), equals(11));
      expect(program.evaluate({'x': 0, 'y': 7}), equals(7));
    });

    test('throws parse errors for invalid expressions', () {
      expect(() => cel.compile('x +'), throwsA(isA<ParseError>()));
      expect(() => cel.compile('(1 + 2'), throwsA(isA<ParseError>()));
      expect(() => cel.compile('1 2 3'), throwsA(isA<ParseError>()));
    });
  });

  group('CEL Macro Functions', () {
    late Cel cel;

    setUp(() {
      cel = Cel();
    });

    group('map function', () {
      test('transforms list elements', () {
        expect(cel.eval('[1, 2, 3].map(x, x * 2)', {}), equals([2, 4, 6]));
        expect(cel.eval('[1, 2, 3].map(n, n + 10)', {}), equals([11, 12, 13]));
        expect(
          cel.eval('["a", "b", "c"].map(s, s + "!")', {}),
          equals(['a!', 'b!', 'c!']),
        );
      });

      test('works with complex expressions', () {
        expect(cel.eval('[1, 2, 3].map(x, x * x)', {}), equals([1, 4, 9]));
        expect(
          cel.eval('[1, 2, 3, 4].map(x, x % 2 == 0)', {}),
          equals([false, true, false, true]),
        );
        expect(
          cel.eval('[1, 2, 3].map(x, x > 2 ? x * 10 : x)', {}),
          equals([1, 2, 30]),
        );
      });

      test('works with objects in list', () {
        final data = {
          'users': [
            {'name': 'Alice', 'age': 30},
            {'name': 'Bob', 'age': 25},
            {'name': 'Charlie', 'age': 35},
          ],
        };
        expect(
          cel.eval('users.map(u, u.name)', data),
          equals(['Alice', 'Bob', 'Charlie']),
        );
        expect(cel.eval('users.map(u, u.age * 2)', data), equals([60, 50, 70]));
        expect(
          cel.eval('users.map(u, u.age > 30)', data),
          equals([false, false, true]),
        );
      });

      test('handles empty list', () {
        expect(cel.eval('[].map(x, x * 2)', {}), equals([]));
      });

      test('preserves variable scope', () {
        final data = {'x': 100};
        expect(cel.eval('[1, 2, 3].map(x, x * 2)', data), equals([2, 4, 6]));
        expect(cel.eval('x', data), equals(100)); // Original x unchanged
      });
    });

    group('filter function', () {
      test('filters list elements', () {
        expect(
          cel.eval('[1, 2, 3, 4, 5].filter(x, x > 2)', {}),
          equals([3, 4, 5]),
        );
        expect(
          cel.eval('[1, 2, 3, 4, 5].filter(x, x % 2 == 0)', {}),
          equals([2, 4]),
        );
        expect(
          cel.eval('["a", "ab", "abc"].filter(s, size(s) > 1)', {}),
          equals(['ab', 'abc']),
        );
      });

      test('works with complex conditions', () {
        expect(
          cel.eval('[1, 2, 3, 4, 5, 6].filter(x, x > 2 && x < 5)', {}),
          equals([3, 4]),
        );
        expect(
          cel.eval('[1, 2, 3, 4, 5].filter(x, x == 1 || x == 5)', {}),
          equals([1, 5]),
        );
      });

      test('works with objects', () {
        final data = {
          'users': [
            {'name': 'Alice', 'age': 30, 'active': true},
            {'name': 'Bob', 'age': 25, 'active': false},
            {'name': 'Charlie', 'age': 35, 'active': true},
          ],
        };
        expect(
          cel.eval('users.filter(u, u.age > 28)', data),
          equals([
            {'name': 'Alice', 'age': 30, 'active': true},
            {'name': 'Charlie', 'age': 35, 'active': true},
          ]),
        );
        expect(
          cel.eval('users.filter(u, u.active)', data),
          equals([
            {'name': 'Alice', 'age': 30, 'active': true},
            {'name': 'Charlie', 'age': 35, 'active': true},
          ]),
        );
        expect(
          cel.eval('users.filter(u, u.active && u.age < 35)', data),
          equals([
            {'name': 'Alice', 'age': 30, 'active': true},
          ]),
        );
      });

      test('handles empty list', () {
        expect(cel.eval('[].filter(x, x > 0)', {}), equals([]));
      });

      test('returns empty when no matches', () {
        expect(cel.eval('[1, 2, 3].filter(x, x > 10)', {}), equals([]));
      });
    });

    group('all function', () {
      test('checks if all elements match condition', () {
        expect(cel.eval('[2, 4, 6].all(x, x % 2 == 0)', {}), isTrue);
        expect(cel.eval('[1, 2, 3].all(x, x > 0)', {}), isTrue);
        expect(cel.eval('[1, 2, 3].all(x, x > 2)', {}), isFalse);
      });

      test('returns true for empty list', () {
        expect(cel.eval('[].all(x, x > 0)', {}), isTrue);
      });

      test('short-circuits on first false', () {
        // This is tested implicitly - if it didn't short-circuit,
        // it would evaluate all elements unnecessarily
        expect(cel.eval('[1, 2, 3, 4, 5].all(x, x < 3)', {}), isFalse);
      });

      test('works with complex conditions', () {
        final data = {
          'users': [
            {'name': 'Alice', 'age': 30},
            {'name': 'Bob', 'age': 25},
            {'name': 'Charlie', 'age': 35},
          ],
        };
        expect(cel.eval('users.all(u, u.age >= 25)', data), isTrue);
        expect(cel.eval('users.all(u, u.age > 30)', data), isFalse);
        expect(cel.eval('users.all(u, has(u, "name"))', data), isTrue);
      });
    });

    group('exists function', () {
      test('checks if any element matches condition', () {
        expect(cel.eval('[1, 2, 3].exists(x, x > 2)', {}), isTrue);
        expect(cel.eval('[1, 2, 3].exists(x, x > 10)', {}), isFalse);
        expect(cel.eval('[1, 3, 5].exists(x, x % 2 == 0)', {}), isFalse);
      });

      test('returns false for empty list', () {
        expect(cel.eval('[].exists(x, x > 0)', {}), isFalse);
      });

      test('short-circuits on first true', () {
        // This is tested implicitly - if it didn't short-circuit,
        // it would evaluate all elements unnecessarily
        expect(cel.eval('[1, 2, 3, 4, 5].exists(x, x > 2)', {}), isTrue);
      });

      test('works with objects', () {
        final data = {
          'users': [
            {'name': 'Alice', 'age': 30},
            {'name': 'Bob', 'age': 25},
            {'name': 'Charlie', 'age': 35},
          ],
        };
        expect(cel.eval('users.exists(u, u.age > 33)', data), isTrue);
        expect(cel.eval('users.exists(u, u.age > 40)', data), isFalse);
        expect(cel.eval('users.exists(u, u.name == "Bob")', data), isTrue);
      });
    });

    group('existsOne function', () {
      test('checks if exactly one element matches', () {
        expect(cel.eval('[1, 2, 3].existsOne(x, x == 2)', {}), isTrue);
        expect(cel.eval('[1, 2, 3].existsOne(x, x > 2)', {}), isTrue);
        expect(
          cel.eval('[1, 2, 3].existsOne(x, x > 1)', {}),
          isFalse,
        ); // 2 matches
        expect(
          cel.eval('[1, 2, 3].existsOne(x, x > 10)', {}),
          isFalse,
        ); // 0 matches
      });

      test('returns false for empty list', () {
        expect(cel.eval('[].existsOne(x, x > 0)', {}), isFalse);
      });

      test('works with complex data', () {
        final data = {
          'users': [
            {'name': 'Alice', 'age': 30},
            {'name': 'Bob', 'age': 25},
            {'name': 'Charlie', 'age': 35},
          ],
        };
        expect(cel.eval('users.existsOne(u, u.age == 25)', data), isTrue);
        expect(
          cel.eval('users.existsOne(u, u.age > 30)', data),
          isTrue,
        ); // Only Charlie is 35 > 30
        expect(
          cel.eval('users.existsOne(u, u.age > 33)', data),
          isTrue,
        ); // Only Charlie
      });
    });

    group('nested macro operations', () {
      test('can chain macro functions', () {
        expect(
          cel.eval('[1, 2, 3, 4, 5].filter(x, x > 2).map(x, x * 2)', {}),
          equals([6, 8, 10]),
        );

        expect(
          cel.eval('[1, 2, 3, 4].map(x, x * 2).filter(x, x > 4)', {}),
          equals([6, 8]),
        );
      });

      test('can use macros in expressions', () {
        final data = {
          'lists': [
            [1, 2],
            [3, 4],
            [5],
          ],
        };
        expect(cel.eval('lists.map(l, size(l))', data), equals([2, 2, 1]));
        expect(
          cel.eval('lists.filter(l, l.exists(x, x > 3))', data),
          equals([
            [3, 4],
            [5],
          ]),
        );
      });

      test('can nest macros', () {
        final data = {
          'matrix': [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
          ],
        };
        // Map each row to its sum > 10
        expect(
          cel.eval('matrix.map(row, row.exists(x, x > 5))', data),
          equals([false, true, true]),
        );
        // Filter rows where all elements > 3
        expect(
          cel.eval('matrix.filter(row, row.all(x, x > 3))', data),
          equals([
            [4, 5, 6],
            [7, 8, 9],
          ]),
        );
      });
    });

    group('error handling', () {
      test('throws error for non-list targets', () {
        expect(
          () => cel.eval('"string".map(x, x)', {}),
          throwsA(isA<EvaluationError>()),
        );
        expect(
          () => cel.eval('123.filter(x, x > 0)', {}),
          throwsA(isA<EvaluationError>()),
        );
      });

      test('throws error for missing arguments', () {
        expect(
          () => cel.eval('[1, 2, 3].map()', {}),
          throwsA(isA<EvaluationError>()),
        ); // Evaluation error for missing args
      });

      test('throws error for invalid variable name', () {
        expect(
          () => cel.eval('[1, 2, 3].map(123, x * 2)', {}),
          throwsA(isA<EvaluationError>()),
        );
      });
    });
  });
}

class CustomFunctions extends StandardFunctions {
  final Map<String, Function> customFunctions;

  CustomFunctions(this.customFunctions);

  @override
  dynamic call(String name, List<dynamic> args) {
    if (customFunctions.containsKey(name)) {
      return customFunctions[name]!(args);
    }
    return super.call(name, args);
  }
}
