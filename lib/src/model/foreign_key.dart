import 'package:meta/meta.dart';

class ForeignKey {
  final String fromTable;

  final String fromColumn;

  final String toTable;

  final String toColumn;

  final String onDelete;

  final String onUpdate;

  final bool isSelfReferencing;

  const ForeignKey({
    @required this.fromTable,
    @required this.fromColumn,
    @required this.toTable,
    @required this.toColumn,
    @required this.onDelete,
    @required this.onUpdate,
  })  : assert(fromTable != null),
        assert(fromColumn != null),
        assert(toTable != null),
        assert(toColumn != null),
        assert(onDelete != null),
        assert(onUpdate != null),
        isSelfReferencing = fromTable == toTable;

  @override
  String toString() {
    return '''ForeignKey{
    fromTable: $fromTable
    fromColumn: $fromColumn
    toTable: $toTable
    toColumn: $toColumn
    onDelete: $onDelete
    onUpdate: $onUpdate
}''';
  }
}
