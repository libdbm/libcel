import 'package:test/test.dart';
import 'package:libcel/libcel.dart';

/// CEL Conformance Tests
/// Based on the official CEL test suite from https://github.com/google/cel-spec
/// These tests ensure our implementation conforms to the CEL specification
void main() {
  late Cel cel;

  setUp(() {
    cel = Cel();
  });

  group('CEL Conformance - Basic', () {
    group('self_eval_zeroish', () {
      test('self_eval_int_zero', () {
        expect(cel.eval('0', {}), equals(0));
      });

      test('self_eval_uint_zero', () {
        // Note: Dart doesn't have unsigned int, treating as regular int
        expect(cel.eval('0', {}), equals(0));
      });

      test('self_eval_float_zero', () {
        expect(cel.eval('0.0', {}), equals(0.0));
      });

      test('self_eval_float_zerowithexp', () {
        expect(cel.eval('0e+0', {}), equals(0.0));
      });

      test('self_eval_string_empty', () {
        expect(cel.eval("''", {}), equals(''));
      });

      test('self_eval_string_empty_quotes', () {
        expect(cel.eval('""', {}), equals(''));
      });

      test('self_eval_bytes_empty', () {
        expect(cel.eval('b""', {}), equals(''));
      });

      test('self_eval_bool_false', () {
        expect(cel.eval('false', {}), equals(false));
      });

      test('self_eval_null', () {
        expect(cel.eval('null', {}), isNull);
      });
    });

    group('self_eval_nonzeroish', () {
      test('self_eval_int_nonzero', () {
        expect(cel.eval('42', {}), equals(42));
        expect(cel.eval('-1', {}), equals(-1));
      });

      test('self_eval_float_nonzero', () {
        expect(cel.eval('3.14', {}), equals(3.14));
        expect(cel.eval('-2.71', {}), equals(-2.71));
      });

      test('self_eval_string_nonempty', () {
        expect(cel.eval('"hello"', {}), equals('hello'));
        expect(cel.eval("'world'", {}), equals('world'));
      });

      test('self_eval_bool_true', () {
        expect(cel.eval('true', {}), equals(true));
      });

      test('self_eval_list', () {
        expect(cel.eval('[1, 2, 3]', {}), equals([1, 2, 3]));
        expect(cel.eval('[]', {}), equals([]));
      });

      test('self_eval_map', () {
        expect(cel.eval('{"a": 1, "b": 2}', {}), equals({'a': 1, 'b': 2}));
        expect(cel.eval('{}', {}), equals({}));
      });
    });
  });

  group('CEL Conformance - Variables', () {
    test('self_eval_bound_identifier', () {
      expect(cel.eval('x', {'x': 123}), equals(123));
      expect(cel.eval('name', {'name': 'Alice'}), equals('Alice'));
    });

    test('self_eval_bound_bool_identifier', () {
      expect(cel.eval('flag', {'flag': true}), equals(true));
      expect(cel.eval('flag', {'flag': false}), equals(false));
    });

    test('self_eval_bound_list_identifier', () {
      expect(
        cel.eval('items', {
          'items': [1, 2, 3],
        }),
        equals([1, 2, 3]),
      );
    });

    test('self_eval_bound_map_identifier', () {
      expect(
        cel.eval('data', {
          'data': {'key': 'value'},
        }),
        equals({'key': 'value'}),
      );
    });
  });

  group('CEL Conformance - Comparisons', () {
    test('eq_literal', () {
      expect(cel.eval('1 == 1', {}), isTrue);
      expect(cel.eval('1 == 2', {}), isFalse);
      expect(cel.eval('"a" == "a"', {}), isTrue);
      expect(cel.eval('true == true', {}), isTrue);
      expect(cel.eval('null == null', {}), isTrue);
    });

    test('ne_literal', () {
      expect(cel.eval('1 != 2', {}), isTrue);
      expect(cel.eval('1 != 1', {}), isFalse);
      expect(cel.eval('"a" != "b"', {}), isTrue);
    });

    test('lt_literal', () {
      expect(cel.eval('1 < 2', {}), isTrue);
      expect(cel.eval('2 < 1', {}), isFalse);
      expect(cel.eval('"a" < "b"', {}), isTrue);
    });

    test('le_literal', () {
      expect(cel.eval('1 <= 2', {}), isTrue);
      expect(cel.eval('1 <= 1', {}), isTrue);
      expect(cel.eval('2 <= 1', {}), isFalse);
    });

    test('gt_literal', () {
      expect(cel.eval('2 > 1', {}), isTrue);
      expect(cel.eval('1 > 2', {}), isFalse);
      expect(cel.eval('"b" > "a"', {}), isTrue);
    });

    test('ge_literal', () {
      expect(cel.eval('2 >= 1', {}), isTrue);
      expect(cel.eval('1 >= 1', {}), isTrue);
      expect(cel.eval('1 >= 2', {}), isFalse);
    });
  });

  group('CEL Conformance - Arithmetic', () {
    test('add_int', () {
      expect(cel.eval('1 + 2', {}), equals(3));
      expect(cel.eval('5 + (-3)', {}), equals(2));
    });

    test('add_float', () {
      expect(cel.eval('1.0 + 2.0', {}), equals(3.0));
      expect(cel.eval('3.14 + 2.86', {}), closeTo(6.0, 0.001));
    });

    test('add_string', () {
      expect(cel.eval('"hello" + " " + "world"', {}), equals('hello world'));
    });

    test('add_list', () {
      expect(cel.eval('[1, 2] + [3, 4]', {}), equals([1, 2, 3, 4]));
    });

    test('sub_int', () {
      expect(cel.eval('5 - 3', {}), equals(2));
      expect(cel.eval('3 - 5', {}), equals(-2));
    });

    test('mul_int', () {
      expect(cel.eval('3 * 4', {}), equals(12));
      expect(cel.eval('-2 * 3', {}), equals(-6));
    });

    test('div_int', () {
      expect(cel.eval('10 / 2', {}), equals(5));
      expect(cel.eval('7 / 2', {}), equals(3.5));
    });

    test('mod_int', () {
      expect(cel.eval('10 % 3', {}), equals(1));
      expect(cel.eval('10 % 5', {}), equals(0));
    });

    test('neg_int', () {
      expect(cel.eval('-5', {}), equals(-5));
      expect(cel.eval('-(3 + 2)', {}), equals(-5));
    });
  });

  group('CEL Conformance - Logic', () {
    test('and', () {
      expect(cel.eval('true && true', {}), isTrue);
      expect(cel.eval('true && false', {}), isFalse);
      expect(cel.eval('false && true', {}), isFalse);
      expect(cel.eval('false && false', {}), isFalse);
    });

    test('or', () {
      expect(cel.eval('true || true', {}), isTrue);
      expect(cel.eval('true || false', {}), isTrue);
      expect(cel.eval('false || true', {}), isTrue);
      expect(cel.eval('false || false', {}), isFalse);
    });

    test('not', () {
      expect(cel.eval('!true', {}), isFalse);
      expect(cel.eval('!false', {}), isTrue);
      expect(cel.eval('!(1 > 2)', {}), isTrue);
    });

    test('conditional', () {
      expect(cel.eval('true ? 1 : 2', {}), equals(1));
      expect(cel.eval('false ? 1 : 2', {}), equals(2));
      expect(cel.eval('2 > 1 ? "yes" : "no"', {}), equals('yes'));
    });
  });

  group('CEL Conformance - Lists', () {
    test('index', () {
      expect(cel.eval('[1, 2, 3][0]', {}), equals(1));
      expect(cel.eval('[1, 2, 3][2]', {}), equals(3));
      expect(cel.eval('["a", "b", "c"][1]', {}), equals('b'));
    });

    test('in_list', () {
      expect(cel.eval('2 in [1, 2, 3]', {}), isTrue);
      expect(cel.eval('4 in [1, 2, 3]', {}), isFalse);
      expect(cel.eval('"b" in ["a", "b", "c"]', {}), isTrue);
    });

    test('size', () {
      expect(cel.eval('size([1, 2, 3])', {}), equals(3));
      expect(cel.eval('size([])', {}), equals(0));
      expect(cel.eval('size([1])', {}), equals(1));
    });
  });

  group('CEL Conformance - Maps', () {
    test('index', () {
      expect(cel.eval('{"a": 1, "b": 2}["a"]', {}), equals(1));
      expect(
        cel.eval('{"x": "hello", "y": "world"}["y"]', {}),
        equals('world'),
      );
    });

    test('field_select', () {
      expect(cel.eval('{"a": 1, "b": 2}.a', {}), equals(1));
      expect(
        cel.eval('{"name": "Alice", "age": 30}.name', {}),
        equals('Alice'),
      );
    });

    test('in_map', () {
      expect(cel.eval('"a" in {"a": 1, "b": 2}', {}), isTrue);
      expect(cel.eval('"c" in {"a": 1, "b": 2}', {}), isFalse);
    });

    test('has', () {
      expect(cel.eval('has({"a": 1}, "a")', {}), isTrue);
      expect(cel.eval('has({"a": 1}, "b")', {}), isFalse);
    });
  });

  group('CEL Conformance - Macros', () {
    group('map', () {
      test('list_empty', () {
        expect(cel.eval('[].map(n, n * n)', {}), equals([]));
      });

      test('list_one', () {
        expect(cel.eval('[3].map(n, n * n)', {}), equals([9]));
      });

      test('list_many', () {
        expect(cel.eval('[2, 4, 6].map(n, n / 2)', {}), equals([1, 2, 3]));
      });

      test('list_maps', () {
        final data = {
          'users': [
            {'name': 'Alice', 'age': 30},
            {'name': 'Bob', 'age': 25},
          ],
        };
        expect(
          cel.eval('users.map(u, u.name)', data),
          equals(['Alice', 'Bob']),
        );
      });
    });

    group('filter', () {
      test('list_empty', () {
        expect(cel.eval('[].filter(n, n > 0)', {}), equals([]));
      });

      test('list_one_true', () {
        expect(cel.eval('[2].filter(n, n == 2)', {}), equals([2]));
      });

      test('list_one_false', () {
        expect(cel.eval('[3].filter(n, n == 2)', {}), equals([]));
      });

      test('list_some', () {
        expect(
          cel.eval('[0, 1, 2, 3, 4].filter(x, x % 2 == 1)', {}),
          equals([1, 3]),
        );
      });
    });

    group('all', () {
      test('list_elem_all_true', () {
        expect(cel.eval('[1, 2, 3].all(e, e > 0)', {}), isTrue);
      });

      test('list_elem_some_true', () {
        expect(cel.eval('[1, 2, 3].all(e, e == 2)', {}), isFalse);
      });

      test('list_elem_none_true', () {
        expect(cel.eval('[1, 2, 3].all(e, e > 10)', {}), isFalse);
      });

      test('list_empty', () {
        expect(cel.eval('[].all(e, e > 0)', {}), isTrue);
      });
    });

    group('exists', () {
      test('list_elem_all_true', () {
        expect(cel.eval('[1, 2, 3].exists(e, e > 0)', {}), isTrue);
      });

      test('list_elem_some_true', () {
        expect(cel.eval('[1, 2, 3].exists(e, e == 2)', {}), isTrue);
      });

      test('list_elem_none_true', () {
        expect(cel.eval('[1, 2, 3].exists(e, e > 10)', {}), isFalse);
      });

      test('list_empty', () {
        expect(cel.eval('[].exists(e, e == 2)', {}), isFalse);
      });
    });

    group('existsOne', () {
      test('list_empty', () {
        expect(cel.eval('[].existsOne(a, a == 7)', {}), isFalse);
      });

      test('list_one_true', () {
        expect(cel.eval('[7].existsOne(a, a == 7)', {}), isTrue);
      });

      test('list_one_match', () {
        expect(cel.eval('[6, 7, 8].existsOne(foo, foo % 5 == 2)', {}), isTrue);
      });

      test('list_many_match', () {
        expect(
          cel.eval('[2, 7, 12].existsOne(foo, foo % 5 == 2)', {}),
          isFalse,
        );
      });

      test('list_no_match', () {
        expect(cel.eval('[1, 2, 3].existsOne(x, x > 10)', {}), isFalse);
      });
    });
  });

  group('CEL Conformance - String Functions', () {
    test('contains', () {
      expect(cel.eval('"hello".contains("ell")', {}), isTrue);
      expect(cel.eval('"hello".contains("abc")', {}), isFalse);
    });

    test('startsWith', () {
      expect(cel.eval('"hello".startsWith("he")', {}), isTrue);
      expect(cel.eval('"hello".startsWith("lo")', {}), isFalse);
    });

    test('endsWith', () {
      expect(cel.eval('"hello".endsWith("lo")', {}), isTrue);
      expect(cel.eval('"hello".endsWith("he")', {}), isFalse);
    });

    test('size', () {
      expect(cel.eval('size("hello")', {}), equals(5));
      expect(cel.eval('size("")', {}), equals(0));
    });

    test('matches', () {
      expect(cel.eval('matches("hello", "h.*o")', {}), isTrue);
      expect(cel.eval('matches("hello", "^h.*o\$")', {}), isTrue);
      expect(cel.eval('matches("hello", "^o.*")', {}), isFalse);
    });
  });

  group('CEL Conformance - Type Conversions', () {
    test('int_conversion', () {
      expect(cel.eval('int(3.14)', {}), equals(3));
      expect(cel.eval('int("42")', {}), equals(42));
      expect(cel.eval('int(true)', {}), equals(1));
      expect(cel.eval('int(false)', {}), equals(0));
    });

    test('double_conversion', () {
      expect(cel.eval('double(42)', {}), equals(42.0));
      expect(cel.eval('double("3.14")', {}), equals(3.14));
    });

    test('string_conversion', () {
      expect(cel.eval('string(42)', {}), equals('42'));
      expect(cel.eval('string(3.14)', {}), equals('3.14'));
      expect(cel.eval('string(true)', {}), equals('true'));
    });

    test('bool_conversion', () {
      expect(cel.eval('bool(1)', {}), isTrue);
      expect(cel.eval('bool(0)', {}), isFalse);
      expect(cel.eval('bool("true")', {}), isTrue);
      expect(cel.eval('bool("")', {}), isFalse);
    });

    test('type_function', () {
      expect(cel.eval('type(42)', {}), equals('int'));
      expect(cel.eval('type(3.14)', {}), equals('double'));
      expect(cel.eval('type("hello")', {}), equals('string'));
      expect(cel.eval('type(true)', {}), equals('bool'));
      expect(cel.eval('type([1, 2])', {}), equals('list'));
      expect(cel.eval('type({"a": 1})', {}), equals('map'));
      expect(cel.eval('type(null)', {}), equals('null'));
    });
  });
}
