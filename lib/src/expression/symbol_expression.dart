/*
class SymbolExpression extends LiteralExpression {
  final String symbolName;

  SymbolExpression(this.symbolName);

  @override
  R accept<R>(ExpressionVisitor<R> visitor, [R context]) {
    return visitor.visitLiteralExpression(this, context);
  }

  @override
  String toString() => '#$symbolName';
}
*/

/*
/// Create a literal Symbol expression from [value].
Expression literalSymbol(String value) {
  assert(value != null);

  return LiteralExpression._('#$value');
}
*/
