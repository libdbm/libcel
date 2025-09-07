/// Base class for all CEL expression nodes in the Abstract Syntax Tree.
/// 
/// Uses the Visitor pattern to enable different operations on expressions
/// such as evaluation, type checking, or code generation.
abstract class Expression {
  /// Accepts a visitor to perform operations on this expression node.
  dynamic accept(Visitor visitor);
}

/// Visitor interface for traversing and operating on AST nodes.
/// 
/// Implements the Visitor pattern to separate algorithms from the data structure.
/// Each visit method corresponds to a specific expression type.
abstract class Visitor<T> {
  /// Visits a literal value expression.
  T visitLiteral(Literal expr);
  
  /// Visits an identifier expression.
  T visitIdentifier(Identifier expr);
  
  /// Visits a field selection expression.
  T visitSelect(Select expr);
  
  /// Visits a function or method call expression.
  T visitCall(Call expr);
  
  /// Visits a list literal expression.
  T visitList(ListExpression expr);
  
  /// Visits a map literal expression.
  T visitMap(MapExpression expr);
  
  /// Visits a struct construction expression.
  T visitStruct(Struct expr);
  
  /// Visits a comprehension expression (list/map generation).
  T visitComprehension(Comprehension expr);
  
  /// Visits a unary operation expression.
  T visitUnary(Unary expr);
  
  /// Visits a binary operation expression.
  T visitBinary(Binary expr);
  
  /// Visits a conditional (ternary) expression.
  T visitConditional(Conditional expr);
  
  /// Visits an index access expression.
  T visitIndex(Index expr);
}

/// Represents a literal value in CEL expressions.
/// 
/// Examples: `null`, `true`, `42`, `3.14`, `"hello"`, `b"bytes"`
class Literal extends Expression {
  /// The actual literal value.
  final dynamic value;
  
  /// The type of the literal value.
  final LiteralType type;

  /// Creates a literal expression with the given value and type.
  Literal(this.value, this.type);

  @override
  dynamic accept(Visitor visitor) => visitor.visitLiteral(this);
}

/// Types of literal values supported in CEL.
enum LiteralType { 
  /// Null value
  nullValue, 
  
  /// Boolean value (true/false)
  bool, 
  
  /// Signed integer
  int, 
  
  /// Unsigned integer
  uint, 
  
  /// Double-precision floating point
  double, 
  
  /// String literal
  string, 
  
  /// Byte string literal
  bytes 
}

/// Represents an identifier reference in CEL expressions.
/// 
/// Examples: `variable`, `myVar`, `user`
class Identifier extends Expression {
  /// The name of the identifier.
  final String name;

  /// Creates an identifier expression with the given name.
  Identifier(this.name);

  @override
  dynamic accept(Visitor visitor) => visitor.visitIdentifier(this);
}

/// Represents field selection in CEL expressions.
/// 
/// Examples: `obj.field`, `user.name`, `has(obj.field)`
class Select extends Expression {
  /// The expression being selected from (null for top-level identifiers).
  final Expression? operand;
  
  /// The name of the field being selected.
  final String field;
  
  /// Whether this is a test-only selection (used with has() macro).
  final bool isTest;

  /// Creates a field selection expression.
  Select({this.operand, required this.field, this.isTest = false});

  @override
  dynamic accept(Visitor visitor) => visitor.visitSelect(this);
}

/// Represents a function call or method invocation in CEL expressions.
/// 
/// Examples: `size(list)`, `obj.method(arg1, arg2)`, `has(obj.field)`
class Call extends Expression {
  /// The target object for method calls (null for function calls).
  final Expression? target;
  
  /// The name of the function or method being called.
  final String function;
  
  /// The arguments passed to the function/method.
  final List<Expression> args;
  
  /// Whether this call represents a CEL macro.
  final bool isMacro;

  /// Creates a function call expression.
  Call({
    this.target,
    required this.function,
    required this.args,
    this.isMacro = false,
  });

  @override
  dynamic accept(Visitor visitor) => visitor.visitCall(this);
}

/// Represents a list literal in CEL expressions.
/// 
/// Examples: `[]`, `[1, 2, 3]`, `["a", "b", "c"]`
class ListExpression extends Expression {
  /// The expressions that evaluate to the list elements.
  final List<Expression> elements;

  /// Creates a list literal expression.
  ListExpression(this.elements);

  @override
  dynamic accept(Visitor visitor) => visitor.visitList(this);
}

/// Represents a map literal in CEL expressions.
/// 
/// Examples: `{}`, `{"key": "value"}`, `{1: "one", 2: "two"}`
class MapExpression extends Expression {
  /// The key-value pairs in the map.
  final List<MapEntry> entries;

  /// Creates a map literal expression.
  MapExpression(this.entries);

  @override
  dynamic accept(Visitor visitor) => visitor.visitMap(this);
}

/// Represents a key-value pair in a map literal.
class MapEntry {
  /// The expression that evaluates to the key.
  final Expression key;
  
  /// The expression that evaluates to the value.
  final Expression value;

  /// Creates a map entry with the given key and value expressions.
  MapEntry(this.key, this.value);
}

/// Represents a struct construction in CEL expressions.
/// 
/// Examples: `Person{name: "John", age: 30}`, `{name: "value"}`
class Struct extends Expression {
  /// The optional type name for the struct.
  final String? type;
  
  /// The field initializations for the struct.
  final List<FieldInitializer> fields;

  /// Creates a struct construction expression.
  Struct({this.type, required this.fields});

  @override
  dynamic accept(Visitor visitor) => visitor.visitStruct(this);
}

/// Represents a field initialization in a struct constructor.
class FieldInitializer {
  /// The name of the field being initialized.
  final String field;
  
  /// The expression that evaluates to the field's value.
  final Expression value;

  /// Creates a field initialization with the given field name and value.
  FieldInitializer(this.field, this.value);
}

/// Represents a comprehension expression for generating lists or maps.
/// 
/// Examples: `[x | x in list]`, `[x*2 | x in range(10) if x % 2 == 0]`
class Comprehension extends Expression {
  /// The name of the iteration variable.
  final String iterVar;
  
  /// The expression that evaluates to the collection being iterated over.
  final Expression iterRange;
  
  /// The name of the accumulator variable (for reduce operations).
  final String accuVar;
  
  /// The initial value of the accumulator.
  final Expression accuInit;
  
  /// The condition that must be true for each iteration.
  final Expression loopCondition;
  
  /// The expression that updates the accumulator in each iteration.
  final Expression loopStep;
  
  /// The expression that produces the final result.
  final Expression result;

  /// Creates a comprehension expression.
  Comprehension({
    required this.iterVar,
    required this.iterRange,
    required this.accuVar,
    required this.accuInit,
    required this.loopCondition,
    required this.loopStep,
    required this.result,
  });

  @override
  dynamic accept(Visitor visitor) => visitor.visitComprehension(this);
}

/// Represents a unary operation in CEL expressions.
/// 
/// Examples: `!condition`, `-value`
class Unary extends Expression {
  /// The unary operator being applied.
  final UnaryOp op;
  
  /// The expression the operator is applied to.
  final Expression operand;

  /// Creates a unary expression with the given operator and operand.
  Unary(this.op, this.operand);

  @override
  dynamic accept(Visitor visitor) => visitor.visitUnary(this);
}

/// Unary operators supported in CEL expressions.
enum UnaryOp { 
  /// Logical NOT operator (!)
  not, 
  
  /// Negation operator (-)
  negate 
}

/// Represents a binary operation in CEL expressions.
/// 
/// Examples: `a + b`, `x == y`, `condition && other`
class Binary extends Expression {
  /// The binary operator being applied.
  final BinaryOp op;
  
  /// The left operand of the binary operation.
  final Expression left;
  
  /// The right operand of the binary operation.
  final Expression right;

  /// Creates a binary expression with the given operator and operands.
  Binary(this.op, this.left, this.right);

  @override
  dynamic accept(Visitor visitor) => visitor.visitBinary(this);
}

/// Binary operators supported in CEL expressions.
enum BinaryOp {
  /// Addition operator (+)
  add,
  
  /// Subtraction operator (-)
  subtract,
  
  /// Multiplication operator (*)
  multiply,
  
  /// Division operator (/)
  divide,
  
  /// Modulo operator (%)
  modulo,
  
  /// Equality operator (==)
  equal,
  
  /// Inequality operator (!=)
  notEqual,
  
  /// Less than operator (<)
  less,
  
  /// Less than or equal operator (<=)
  lessEqual,
  
  /// Greater than operator (>)
  greater,
  
  /// Greater than or equal operator (>=)
  greaterEqual,
  
  /// Logical AND operator (&&)
  logicalAnd,
  
  /// Logical OR operator (||)
  logicalOr,
  
  /// Membership test operator (in)
  inOp,
}

/// Represents a conditional (ternary) expression in CEL.
/// 
/// Example: `condition ? thenValue : elseValue`
class Conditional extends Expression {
  /// The condition expression that determines which branch to take.
  final Expression condition;
  
  /// The expression to evaluate if the condition is true.
  final Expression thenExpr;
  
  /// The expression to evaluate if the condition is false.
  final Expression elseExpr;

  /// Creates a conditional expression.
  Conditional({
    required this.condition,
    required this.thenExpr,
    required this.elseExpr,
  });

  @override
  dynamic accept(Visitor visitor) => visitor.visitConditional(this);
}

/// Represents an index access operation in CEL expressions.
/// 
/// Examples: `list[0]`, `map["key"]`, `array[i]`
class Index extends Expression {
  /// The expression being indexed (list, map, or string).
  final Expression operand;
  
  /// The expression that evaluates to the index value.
  final Expression index;

  /// Creates an index access expression.
  Index(this.operand, this.index);

  @override
  dynamic accept(Visitor visitor) => visitor.visitIndex(this);
}
