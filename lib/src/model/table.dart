import 'package:meta/meta.dart';

import 'column.dart';
import 'foreign_key.dart';

class Table {
  final String name;

  final List<Column> columns;

  final List<ForeignKey> foreignKeys;

  const Table({
    @required this.name,
    @required this.columns,
    @required this.foreignKeys,
  })  : assert(name != null),
        assert(columns != null),
        assert(foreignKeys != null);

  @override
  String toString() {
    return '''Table{
    name: $name
    columns: $columns
    foreignKeys: $foreignKeys
}''';
  }
}
