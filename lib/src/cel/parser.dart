import 'package:petitparser/petitparser.dart';
import 'ast.dart';

class CelGrammar extends GrammarDefinition {
  // start = expr EOF
  @override
  Parser start() => ref0(expr).end();

  // expr = conditionalOr ( '?' conditionalOr ':' expr )?
  Parser expr() => ref0(conditionalOr).seq(
    (string('?')
            .trim()
            .seq(ref0(conditionalOr))
            .seq(string(':').trim())
            .seq(ref0(expr)))
        .optional(),
  );

  // conditionalOr = conditionalAnd ( '||' conditionalAnd )*
  Parser conditionalOr() => ref0(
    conditionalAnd,
  ).starSeparated(string('||').trim()).map((list) => list.elements);

  // conditionalAnd = relation ( '&&' relation )*
  Parser conditionalAnd() => ref0(
    relation,
  ).starSeparated(string('&&').trim()).map((list) => list.elements);

  // relation = addition ( relop addition )*
  Parser relation() => ref0(addition).starSeparated(ref0(relop)).map((list) {
    if (list.elements.isEmpty) return [];
    final result = [];
    for (int i = 0; i < list.elements.length; i++) {
      result.add(list.elements[i]);
      if (i < list.separators.length) {
        result.add(list.separators[i]);
      }
    }
    return result;
  });

  // relop = '<=' | '>=' | '!=' | '==' | '<' | '>' | 'in'
  Parser relop() =>
      (string('<=') |
              string('>=') |
              string('!=') |
              string('==') |
              string('<') |
              string('>') |
              string('in'))
          .trim();

  // addition = multiplication ( ('+' | '-') multiplication )*
  Parser addition() => ref0(multiplication)
      .starSeparated((char('+') | char('-')).trim())
      .map((list) {
        if (list.elements.isEmpty) return [];
        final result = [];
        for (int i = 0; i < list.elements.length; i++) {
          result.add(list.elements[i]);
          if (i < list.separators.length) {
            result.add(list.separators[i]);
          }
        }
        return result;
      });

  // multiplication = unary ( ('*' | '/' | '%') unary )*
  Parser multiplication() => ref0(unary)
      .starSeparated((char('*') | char('/') | char('%')).trim())
      .map((list) {
        if (list.elements.isEmpty) return [];
        final result = [];
        for (int i = 0; i < list.elements.length; i++) {
          result.add(list.elements[i]);
          if (i < list.separators.length) {
            result.add(list.separators[i]);
          }
        }
        return result;
      });

  // unary = '!'+ member | '-'+ member | member
  Parser unary() =>
      (char('!').trim().plus() & ref0(member)) |
      (char('-').trim().plus() & ref0(member)) |
      ref0(member);

  // member = primary ( selector | index | fieldCall )*
  Parser member() =>
      ref0(primary) & (ref0(selector) | ref0(index) | ref0(fieldCall)).star();

  // selector = '.' ident callArgs?
  Parser selector() =>
      char('.').trim() & ref0(ident) & ref0(callArgs).optional();

  // fieldCall = '.' ident '(' exprList? ')'
  Parser fieldCall() =>
      char('.').trim() &
      ref0(ident) &
      char('(').trim() &
      ref0(exprList).optional() &
      char(')').trim();

  // index = '[' expr ']'
  Parser index() => char('[').trim() & ref0(expr) & char(']').trim();

  // callArgs = '(' exprList? ')'
  Parser callArgs() =>
      char('(').trim() & ref0(exprList).optional() & char(')').trim();

  // primary = literal
  //         | ident callArgs?
  //         | listLiteral
  //         | mapLiteral
  //         | structLiteral
  //         | '(' expr ')'
  //         | '.' ident callArgs?
  Parser primary() =>
      ref0(literal) |
      ref0(ident).seq(ref0(callArgs).optional()) |
      ref0(listLiteral) |
      ref0(mapLiteral) |
      ref0(structLiteral) |
      (char('(').trim() & ref0(expr) & char(')').trim()) |
      (char('.').trim() & ref0(ident).seq(ref0(callArgs).optional()));

  // listLiteral = '[' exprList? ','? ']'
  Parser listLiteral() =>
      char('[').trim() &
      ref0(exprList).optional() &
      char(',').trim().optional() &
      char(']').trim();

  // mapLiteral = '{' mapInits? ','? '}'
  Parser mapLiteral() =>
      char('{').trim() &
      ref0(mapInits).optional() &
      char(',').trim().optional() &
      char('}').trim();

  // structLiteral = qualifiedIdent? '{' fieldInits? ','? '}'
  Parser structLiteral() =>
      ref0(qualifiedIdent).optional() &
      char('{').trim() &
      ref0(fieldInits).optional() &
      char(',').trim().optional() &
      char('}').trim();

  // exprList = expr ( ',' expr )*
  Parser exprList() =>
      ref0(expr).starSeparated(char(',').trim()).map((list) => list.elements);

  // mapInits = mapInit ( ',' mapInit )*
  Parser mapInits() => ref0(
    mapInit,
  ).starSeparated(char(',').trim()).map((list) => list.elements);

  // mapInit = expr ':' expr
  Parser mapInit() => ref0(expr) & char(':').trim() & ref0(expr);

  // fieldInits = fieldInit ( ',' fieldInit )*
  Parser fieldInits() => ref0(
    fieldInit,
  ).starSeparated(char(',').trim()).map((list) => list.elements);

  // fieldInit = ident ':' expr
  Parser fieldInit() => ref0(ident) & char(':').trim() & ref0(expr);

  // qualifiedIdent = ident ( '.' ident )*
  Parser qualifiedIdent() =>
      ref0(ident) & (char('.').trim() & ref0(ident)).star();

  // ident = [a-zA-Z_] [a-zA-Z0-9_]*
  Parser ident() =>
      pattern('a-zA-Z_').seq(pattern('a-zA-Z0-9_').star()).flatten().trim();

  // literal = nullLiteral
  //         | boolLiteral
  //         | doubleLiteral
  //         | intLiteral
  //         | uintLiteral
  //         | stringLiteral
  //         | bytesLiteral
  Parser literal() =>
      ref0(nullLiteral) |
      ref0(boolLiteral) |
      ref0(doubleLiteral) | // Check double before int (handles exponential)
      ref0(uintLiteral) |  // Check uint before int (handles 'u' suffix)
      ref0(intLiteral) |
      ref0(stringLiteral) |
      ref0(bytesLiteral);

  // nullLiteral = 'null'
  Parser nullLiteral() => string('null').trim();

  // boolLiteral = 'true' | 'false
  Parser boolLiteral() => (string('true') | string('false')).trim();

  // intLiteral = '-'? ( '0x' [0-9a-fA-F]+ | [0-9]+ )
  Parser intLiteral() =>
      (char('-').optional() &
              (
                  // Hexadecimal: 0x[0-9a-fA-F]+
                  (string('0x') & pattern('0-9a-fA-F').plus()) |
                  // Decimal: [0-9]+
                  (digit().plus() &
                      (char('.') & digit().plus()).not() &
                      pattern('eE').not()) // Exclude exponential notation
              ))
          .flatten()
          .trim();

  // uintLiteral = ( '0x' [0-9a-fA-F]+ | [0-9]+ ) [uU]
  Parser uintLiteral() => 
      ((
          // Hexadecimal: 0x[0-9a-fA-F]+
          (string('0x') & pattern('0-9a-fA-F').plus()) |
          // Decimal: [0-9]+
          digit().plus()
      ) & pattern('uU')).flatten().trim();

  // doubleLiteral = '-'? [0-9]+ ( '.' [0-9]+ ( [eE] [+-]? [0-9]+ )? | [eE] [+-]? [0-9]+ )
  Parser doubleLiteral() =>
      (
          // Format: -123.456e+10 or -123e+10 or 123.456
          char('-').optional() &
              digit().plus() &
              (
              // Either: .456e+10 or .456
              (char('.') &
                      digit().plus() &
                      (pattern('eE') &
                              pattern('+-').optional() &
                              digit().plus())
                          .optional()) |
                  // Or: e+10 (no decimal point, but has exponent)
                  (pattern('eE') & pattern('+-').optional() & digit().plus())))
          .flatten()
          .trim();

  // stringLiteral = rawString | interpretedString | tripleQuotedString
  Parser stringLiteral() => 
      (ref0(tripleQuotedString) | ref0(rawString) | ref0(interpretedString)).trim();

  // rawString = [rR] ( '"' [^"]* '"' | "'" [^']* "'" )
  Parser rawString() =>
      (
          // r"string" or r'string'
          pattern('rR') &
              ((char('"') & char('"').neg().star() & char('"')) |
                  (char("'") & char("'").neg().star() & char("'"))))
          .flatten();

  /// interpretedString = '"' ( escapeSequence | [^"\\] )* '"' | "'" ( escapeSequence | [^'\\] )* "'"
  Parser interpretedString() =>
      (
          // "string" or 'string'
          ((char('"') &
                  (ref0(escapeSequence) | pattern('^"\\\\')).star() &
                  char('"')) |
              (char("'") &
                  (ref0(escapeSequence) | pattern("^'\\\\")).star() &
                  char("'"))))
          .flatten();

  /// tripleQuotedString = [rR]? '"""' ... '"""' | [rR]? "'''" ... "'''"
  Parser tripleQuotedString() =>
      (
          // Optional raw prefix
          pattern('rR').optional() &
          (
              // """string""" - allows any content including newlines
              (string('"""') & 
                  (
                      // Match anything except """ 
                      // This allows single or double quotes, but not triple quotes
                      (string('"""').not() & any()).star()
                  ) &
                  string('"""')) |
              // '''string''' - allows any content including newlines
              (string("'''") & 
                  (
                      // Match anything except '''
                      (string("'''").not() & any()).star()
                  ) &
                  string("'''"))
          )
      ).flatten();

  /// escapeSequence = '\\' ( '\\' | '"' | "'" | '`' | '?' | 'a' | 'b' | 'f' | 'n' | 'r' | 't' | 'v' | [0-3][0-7][0-7] | 'x' [0-9a-fA-F]{2} | 'u' [0-9a-fA-F]{4} | 'U' [0-9a-fA-F]{8} )
  Parser escapeSequence() =>
      char('\\') &
      (char('\\') |
          char('"') |
          char('\'') |
          char('`') |
          char('?') |
          char('a') |
          char('b') |
          char('f') |
          char('n') |
          char('r') |
          char('t') |
          char('v') |
          (pattern('0-3') & pattern('0-7') & pattern('0-7')) | // octal escape
          (char('x') & pattern('0-9a-fA-F').times(2)) |
          (char('u') & pattern('0-9a-fA-F').times(4)) |
          (char('U') & pattern('0-9a-fA-F').times(8)));

  /// bytesLiteral = [bB] ( '"' ( escapeSequence | [^"\\] )* '"' | "'" ( escapeSequence | [^'\\] )* "'" )
  Parser bytesLiteral() =>
      (
          // b"bytes" or B"bytes" or b'bytes' or B'bytes'
          pattern('bB') &
              ((char('"') &
                      (ref0(escapeSequence) | pattern('^"\\\\')).star() &
                      char('"')) |
                  (char("'") &
                      (ref0(escapeSequence) | pattern("^'\\\\")).star() &
                      char("'"))))
          .flatten()
          .trim();
}

class CelParser {
  final Parser _parser;

  CelParser() : _parser = CelParserDefinition().build();

  Result<dynamic> parse(String input) {
    return _parser.parse(input);
  }
}

class CelParserDefinition extends CelGrammar {
  @override
  Parser expr() => super.expr().map((values) {
    final expr = values[0];
    final conditional = values[1];

    if (conditional != null) {
      final parts = conditional as List;
      final thenExpr = parts[1];
      final elseExpr = parts[3];
      return Conditional(
        condition: expr,
        thenExpr: thenExpr,
        elseExpr: elseExpr,
      );
    }
    return expr;
  });

  @override
  Parser conditionalOr() => super.conditionalOr().map((values) {
    final List<dynamic> exprs = values;
    if (exprs.length == 1) return exprs[0];
    return exprs
        .skip(1)
        .fold(
          exprs[0],
          (left, right) => Binary(BinaryOp.logicalOr, left, right),
        );
  });

  @override
  Parser conditionalAnd() => super.conditionalAnd().map((values) {
    final List<dynamic> exprs = values;
    if (exprs.length == 1) return exprs[0];
    return exprs
        .skip(1)
        .fold(
          exprs[0],
          (left, right) => Binary(BinaryOp.logicalAnd, left, right),
        );
  });

  @override
  Parser relation() => super.relation().map((values) {
    final List parts = values;
    if (parts.isEmpty) return null;
    if (parts.length == 1) return parts[0];

    final firstExpr = parts[0] as Expression?;
    if (firstExpr == null) return null;

    Expression result = firstExpr;
    for (int i = 1; i < parts.length; i += 2) {
      if (i + 1 >= parts.length) return null; // Incomplete expression
      final op = parts[i] as String;
      final right = parts[i + 1] as Expression?;
      if (right == null) return null; // Incomplete expression

      final binaryOp = switch (op) {
        '<' => BinaryOp.less,
        '<=' => BinaryOp.lessEqual,
        '>' => BinaryOp.greater,
        '>=' => BinaryOp.greaterEqual,
        '==' => BinaryOp.equal,
        '!=' => BinaryOp.notEqual,
        'in' => BinaryOp.inOp,
        _ => throw ArgumentError('Unknown relational operator: $op'),
      };

      result = Binary(binaryOp, result, right);
    }
    return result;
  });

  @override
  Parser addition() => super.addition().map((values) {
    final List parts = values;
    if (parts.isEmpty) return null;
    if (parts.length == 1) return parts[0];

    final firstExpr = parts[0] as Expression?;
    if (firstExpr == null) return null;

    Expression result = firstExpr;
    for (int i = 1; i < parts.length; i += 2) {
      if (i + 1 >= parts.length) return null; // Incomplete expression
      final op = parts[i] as String;
      final right = parts[i + 1] as Expression?;
      if (right == null) return null; // Incomplete expression

      final binaryOp = op == '+' ? BinaryOp.add : BinaryOp.subtract;
      result = Binary(binaryOp, result, right);
    }
    return result;
  });

  @override
  Parser multiplication() => super.multiplication().map((values) {
    final List parts = values;
    if (parts.isEmpty) return null;
    if (parts.length == 1) return parts[0];

    final firstExpr = parts[0] as Expression?;
    if (firstExpr == null) return null;

    Expression result = firstExpr;
    for (int i = 1; i < parts.length; i += 2) {
      if (i + 1 >= parts.length) return null; // Incomplete expression
      final op = parts[i] as String;
      final right = parts[i + 1] as Expression?;
      if (right == null) return null; // Incomplete expression

      final binaryOp = switch (op) {
        '*' => BinaryOp.multiply,
        '/' => BinaryOp.divide,
        '%' => BinaryOp.modulo,
        _ => throw ArgumentError('Unknown multiplicative operator: $op'),
      };

      result = Binary(binaryOp, result, right);
    }
    return result;
  });

  @override
  Parser unary() => super.unary().map((values) {
    if (values is List && values.length == 2) {
      final ops = values[0] as List;
      final operand = values[1] as Expression;

      if (ops.isNotEmpty) {
        final firstOp = ops[0] as String;
        if (firstOp == '!') {
          return ops.fold(operand, (expr, _) => Unary(UnaryOp.not, expr));
        } else if (firstOp == '-') {
          return ops.fold(operand, (expr, _) => Unary(UnaryOp.negate, expr));
        }
      }
    }
    return values;
  });

  @override
  Parser member() => super.member().map((values) {
    final primary = values[0] as Expression;
    final suffixes = values[1] as List;

    return suffixes.fold(primary, (expr, suffix) {
      if (suffix is List) {
        if (suffix[0] == '.') {
          // Check if this is a fieldCall (has 5 parts: '.', ident, '(', exprList?, ')')
          if (suffix.length >= 5 && suffix[2] == '(') {
            final field = suffix[1] as String;
            final exprList = suffix[3] as List<dynamic>?;
            if (exprList == null || exprList.isEmpty) {
              return Call(target: expr, function: field, args: <Expression>[]);
            }
            // Check if this is a macro call (map, filter, all, exists, existsOne)
            final isMacro = _isMacroMethod(field);
            return Call(
              target: expr,
              function: field,
              args: exprList.whereType<Expression>().toList(),
              isMacro: isMacro,
            );
          }
          // Otherwise it's a selector with optional call args
          final field = suffix[1] as String;
          if (suffix.length > 2 && suffix[2] != null) {
            final args = suffix[2] as List?;
            if (args != null && args[0] == '(') {
              final exprList = args[1] as List<dynamic>?;
              if (exprList == null || exprList.isEmpty) {
                return Call(target: expr, function: field, args: <Expression>[]);
              }
              // Check if this is a macro call
              final isMacro = _isMacroMethod(field);
              return Call(
                target: expr,
                function: field,
                args: exprList.whereType<Expression>().toList(),
                isMacro: isMacro,
              );
            }
          }
          return Select(operand: expr, field: field);
        } else if (suffix[0] == '[') {
          final index = suffix[1] as Expression;
          return Index(expr, index);
        }
      }
      return expr;
    });
  });

  @override
  Parser primary() => super.primary().map((values) {
    if (values is Expression) return values;

    if (values is List) {
      if (values.isNotEmpty) {
        if (values[0] == '(') {
          return values[1] as Expression;
        } else if (values[0] == '.') {
          final ident = values[1];
          if (ident is List) {
            final name = ident[0] as String;
            final args = ident[1];
            if (args != null && args is List && args[0] == '(') {
              final exprList = args[1] as List<dynamic>?;
              if (exprList == null || exprList.isEmpty) {
                return Call(target: null, function: name, args: <Expression>[]);
              }
              return Call(
                target: null,
                function: name,
                args: exprList.whereType<Expression>().toList(),
              );
            }
            return Select(operand: null, field: name);
          }
        } else if (values[0] is String) {
          final name = values[0] as String;
          final args = values.length > 1 ? values[1] : null;
          if (args != null && args is List && args[0] == '(') {
            final exprList =
                (args[1] as List<dynamic>?)?.cast<Expression>() ?? <Expression>[];
            return Call(target: null, function: name, args: exprList);
          }
          return Identifier(name);
        }
      }
    }

    return values;
  });

  @override
  Parser listLiteral() => super.listLiteral().map((values) {
    final elements = values[1] as List<dynamic>?;
    if (elements == null || elements.isEmpty) {
      return ListExpression(<Expression>[]);
    }
    return ListExpression(elements.whereType<Expression>().toList());
  });

  @override
  Parser mapLiteral() => super.mapLiteral().map((values) {
    final inits = values[1] as List? ?? [];
    final entries = inits.map((init) {
      final parts = init as List;
      return MapEntry(parts[0] as Expression, parts[2] as Expression);
    }).toList();
    return MapExpression(entries);
  });

  @override
  Parser structLiteral() => super.structLiteral().map((values) {
    final type = values[0] as String?;
    final inits = values[2] as List? ?? [];
    final fields = inits.map((init) {
      final parts = init as List;
      return FieldInitializer(parts[0] as String, parts[2] as Expression);
    }).toList();
    return Struct(type: type, fields: fields);
  });

  @override
  Parser nullLiteral() =>
      super.nullLiteral().map((_) => Literal(null, LiteralType.nullValue));

  @override
  Parser boolLiteral() => super.boolLiteral().map(
    (value) => Literal(value == 'true', LiteralType.bool),
  );

  @override
  Parser intLiteral() => super.intLiteral().map((value) {
    final str = value as String;
    // Handle hexadecimal (0x...) and decimal integers
    if (str.startsWith('0x') || str.startsWith('-0x')) {
      // Parse hexadecimal
      if (str.startsWith('-')) {
        return Literal(-int.parse(str.substring(3), radix: 16), LiteralType.int);
      } else {
        return Literal(int.parse(str.substring(2), radix: 16), LiteralType.int);
      }
    } else {
      // Parse decimal
      return Literal(int.parse(str), LiteralType.int);
    }
  });

  @override
  Parser uintLiteral() => super.uintLiteral().map((value) {
    var str = value as String;
    // Remove the 'u' or 'U' suffix
    str = str.substring(0, str.length - 1);
    // Handle hexadecimal (0x...) and decimal integers
    if (str.startsWith('0x')) {
      return Literal(int.parse(str.substring(2), radix: 16), LiteralType.uint);
    } else {
      return Literal(int.parse(str), LiteralType.uint);
    }
  });

  @override
  Parser doubleLiteral() => super.doubleLiteral().map(
    (value) => Literal(double.parse(value), LiteralType.double),
  );

  @override
  Parser stringLiteral() => super.stringLiteral().map((value) {
    String str = value as String;
    bool isRaw = str.startsWith('r') || str.startsWith('R');
    
    if (isRaw && (str.substring(1).startsWith('"""') || str.substring(1).startsWith("'''"))) {
      // Raw triple-quoted string: r"""...""" or r'''...'''
      str = str.substring(4, str.length - 3);
      // Raw strings don't process escape sequences
    } else if (str.startsWith('"""') || str.startsWith("'''")) {
      // Triple-quoted string: """...""" or '''...'''
      str = str.substring(3, str.length - 3);
      str = _unescapeString(str);
    } else if (isRaw) {
      // Raw string: r"..." or r'...'
      str = str.substring(2, str.length - 1);
      // Raw strings don't process escape sequences
    } else {
      // Regular string: "..." or '...'
      str = str.substring(1, str.length - 1);
      str = _unescapeString(str);
    }
    return Literal(str, LiteralType.string);
  });

  @override
  Parser bytesLiteral() => super.bytesLiteral().map((value) {
    String str = value as String;
    str = str.substring(2, str.length - 1);
    return Literal(str, LiteralType.bytes);
  });

  String _unescapeString(String str) {
    final buffer = StringBuffer();
    int i = 0;
    
    while (i < str.length) {
      if (str[i] == '\\' && i + 1 < str.length) {
        final next = str[i + 1];
        switch (next) {
          case '\\':
            buffer.write('\\');
            i += 2;
            break;
          case '"':
            buffer.write('"');
            i += 2;
            break;
          case "'":
            buffer.write("'");
            i += 2;
            break;
          case '`':
            buffer.write('`');
            i += 2;
            break;
          case '?':
            buffer.write('?');
            i += 2;
            break;
          case 'a':
            buffer.write('\x07'); // bell/alert
            i += 2;
            break;
          case 'b':
            buffer.write('\x08'); // backspace
            i += 2;
            break;
          case 'f':
            buffer.write('\x0C'); // form feed
            i += 2;
            break;
          case 'n':
            buffer.write('\n');
            i += 2;
            break;
          case 'r':
            buffer.write('\r');
            i += 2;
            break;
          case 't':
            buffer.write('\t');
            i += 2;
            break;
          case 'v':
            buffer.write('\x0B'); // vertical tab
            i += 2;
            break;
          case 'x':
            // Hexadecimal escape: \xHH
            if (i + 3 < str.length) {
              final hex = str.substring(i + 2, i + 4);
              buffer.writeCharCode(int.parse(hex, radix: 16));
              i += 4;
            } else {
              buffer.write(str[i]);
              i++;
            }
            break;
          case 'u':
            // Unicode escape: \uHHHH
            if (i + 5 < str.length) {
              final hex = str.substring(i + 2, i + 6);
              buffer.writeCharCode(int.parse(hex, radix: 16));
              i += 6;
            } else {
              buffer.write(str[i]);
              i++;
            }
            break;
          case 'U':
            // Unicode escape: \UHHHHHHHH
            if (i + 9 < str.length) {
              final hex = str.substring(i + 2, i + 10);
              buffer.writeCharCode(int.parse(hex, radix: 16));
              i += 10;
            } else {
              buffer.write(str[i]);
              i++;
            }
            break;
          default:
            // Check for octal escape: \[0-3][0-7][0-7]
            if (i + 3 < str.length && 
                RegExp(r'^[0-3][0-7][0-7]$').hasMatch(str.substring(i + 1, i + 4))) {
              final octal = str.substring(i + 1, i + 4);
              buffer.writeCharCode(int.parse(octal, radix: 8));
              i += 4;
            } else {
              buffer.write(str[i]);
              i++;
            }
            break;
        }
      } else {
        buffer.write(str[i]);
        i++;
      }
    }
    
    return buffer.toString();
  }

  bool _isMacroMethod(String method) {
    return {'map', 'filter', 'all', 'exists', 'existsOne'}.contains(method);
  }
}
