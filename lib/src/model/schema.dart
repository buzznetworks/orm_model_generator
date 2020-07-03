import 'package:meta/meta.dart';

import 'table.dart';

class Schema {
  final String name;

  final List<Table> tables;

  const Schema({
    @required this.name,
    @required this.tables,
  })  : assert(name != null),
        assert(tables != null);

  @override
  String toString() {
    return '''Schema{
    name: $name
    tables: $tables
}''';
  }
}
