# CEL (Common Expression Language) EBNF Grammar

This file defines the Extended Backus-Naur Form (EBNF) grammar for CEL expressions.

## Grammar Productions

```ebnf
# Entry point
start = expr EOF

# Conditional expressions (ternary operator)
expr = conditionalOr ( '?' conditionalOr ':' expr )?

# Logical operators (lowest precedence)
conditionalOr = conditionalAnd ( '||' conditionalAnd )*
conditionalAnd = relation ( '&&' relation )*

# Relational operators
relation = addition ( relop addition )*
relop = '<=' | '>=' | '!=' | '==' | '<' | '>' | 'in'

# Arithmetic operators
addition = multiplication ( ('+' | '-') multiplication )*
multiplication = unary ( ('*' | '/' | '%') unary )*

# Unary operators
unary = '!'+ member | '-'+ member | member

# Member access and function calls
member = primary ( selector | index | fieldCall )*
selector = '.' ident callArgs?
fieldCall = '.' ident '(' exprList? ')'
index = '[' expr ']'
callArgs = '(' exprList? ')'

# Primary expressions
primary = literal 
        | ident callArgs? 
        | listLiteral 
        | mapLiteral 
        | structLiteral 
        | '(' expr ')' 
        | '.' ident callArgs?

# Literals
literal = nullLiteral 
        | boolLiteral 
        | doubleLiteral 
        | intLiteral 
        | uintLiteral 
        | stringLiteral 
        | bytesLiteral

nullLiteral = 'null'
boolLiteral = 'true' | 'false'

# Numeric literals
intLiteral = '-'? ( '0x' [0-9a-fA-F]+ | [0-9]+ )
uintLiteral = ( '0x' [0-9a-fA-F]+ | [0-9]+ ) [uU]
doubleLiteral = '-'? [0-9]+ ( '.' [0-9]+ ( [eE] [+-]? [0-9]+ )? | [eE] [+-]? [0-9]+ )

# String literals
stringLiteral = rawString | interpretedString | tripleQuotedString | rawTripleQuotedString
rawString = [rR] ( '"' [^"]* '"' | "'" [^']* "'" )
interpretedString = '"' ( escapeSequence | [^"\\] )* '"' 
                  | "'" ( escapeSequence | [^'\\] )* "'"
tripleQuotedString = '"""' ( escapeSequence | [^\\] | '"' '"'? [^"] )* '"""'
                   | "'''" ( escapeSequence | [^\\] | "'" "'"? [^'] )* "'''"
rawTripleQuotedString = [rR] '"""' .*? '"""' 
                      | [rR] "'''" .*? "'''"

# Byte literals
bytesLiteral = [bB] ( '"' ( escapeSequence | [^"\\] )* '"' 
                    | "'" ( escapeSequence | [^'\\] )* "'" )

# Escape sequences
escapeSequence = '\\' ( '\\' | '"' | "'" | '`' | '?' 
                      | 'a' | 'b' | 'f' | 'n' | 'r' | 't' | 'v'
                      | [0-3] [0-7] [0-7]  # octal escape
                      | 'x' [0-9a-fA-F]{2} 
                      | 'u' [0-9a-fA-F]{4} 
                      | 'U' [0-9a-fA-F]{8} )

# Collection literals
listLiteral = '[' exprList? ','? ']'
mapLiteral = '{' mapInits? ','? '}'
structLiteral = qualifiedIdent? '{' fieldInits? ','? '}'

# Expression lists and initializers
exprList = expr ( ',' expr )*
mapInits = mapInit ( ',' mapInit )*
mapInit = expr ':' expr
fieldInits = fieldInit ( ',' fieldInit )*
fieldInit = ident ':' expr

# Identifiers
qualifiedIdent = ident ( '.' ident )*
ident = [a-zA-Z_] [a-zA-Z0-9_]*
```

## Operator Precedence (highest to lowest)

1. **Primary expressions**: literals, identifiers, parentheses, member access
2. **Unary operators**: `!` (logical NOT), `-` (negation)
3. **Multiplicative**: `*`, `/`, `%`
4. **Additive**: `+`, `-`
5. **Relational**: `<`, `<=`, `>`, `>=`, `==`, `!=`, `in`
6. **Logical AND**: `&&`
7. **Logical OR**: `||`
8. **Conditional**: `? :`

## Examples

### Basic Expressions
- `42` - Integer literal
- `0x2A` - Hexadecimal integer literal  
- `42u` - Unsigned integer literal
- `0xFFu` - Unsigned hexadecimal literal
- `3.14` - Double literal
- `2.5e10` - Scientific notation
- `"hello"` - String literal
- `'world'` - Single-quoted string
- `"""multi
  line"""` - Triple-quoted string literal
- `r"raw\nstring"` - Raw string (no escape processing)
- `R'''raw
  triple'''` - Raw triple-quoted string
- `b"bytes"` - Bytes literal
- `B'\x00\xFF'` - Bytes with hex escapes
- `true` - Boolean literal
- `null` - Null literal

### Arithmetic
- `a + b * c` - Mixed arithmetic with precedence
- `(a + b) * c` - Parentheses override precedence
- `-x` - Unary negation

### Comparisons
- `x == y` - Equality
- `a < b && b < c` - Chained comparisons
- `value in [1, 2, 3]` - Membership test

### Member Access
- `obj.field` - Field selection
- `obj.method()` - Method call
- `list[0]` - Index access
- `map["key"]` - Map access

### Collections
- `[1, 2, 3]` - List literal
- `{"key": "value"}` - Map literal
- `Person{name: "John", age: 30}` - Struct literal

### Conditional
- `condition ? trueValue : falseValue` - Ternary operator

## Reserved Keywords

The following keywords are reserved and cannot be used as identifiers:

```
false  in  null  true
```

Additional reserved for future use:
```
as  break  const  continue  else  for  function  if  
import  let  loop  package  namespace  return  var  void  while
```

## Notes

- CEL is designed for safe expression evaluation in constrained environments
- All operations are side-effect free
- Type system prevents runtime errors through compile-time checking
- Supports rich built-in functions for string, list, and map operations
- Grammar is fully compliant with Google CEL specification