import 'package:meta/meta.dart';

import './foreign_key.dart';

class Column {
  final String name;

  final String description;

  final String databaseType;

  final String dartType;

  final String defaultValue;

  final bool isEnum;

  final bool isGenerated;

  final bool isIndexed;

  final bool isNullable;

  final bool isPrimaryKey;

  final bool isForeignKey;

  final bool isUnique;

  final List<String> enumValues;

  final ForeignKey foreignKey;

  const Column({
    @required this.name,
    this.description,
    @required this.dartType,
    @required this.databaseType,
    this.defaultValue,
    this.isGenerated = false,
    this.isIndexed = false,
    this.isNullable = false,
    this.isPrimaryKey = false,
    this.isUnique = false,
    this.enumValues,
    this.foreignKey,
  })  : assert(name != null),
        assert(dartType != null),
        assert(databaseType != null),
        assert(isGenerated != null),
        assert(isIndexed != null),
        assert(isNullable != null),
        assert(isPrimaryKey != null),
        assert(isUnique != null),
        isEnum = enumValues != null,
        isForeignKey = foreignKey != null;

  @override
  String toString() {
    return '''Column{
    name: $name
    description: $description
    dartType: $dartType
    sqlType: $databaseType
    defaultValue: $defaultValue
    isEnum: $isEnum
    isGenerated: $isGenerated
    isIndexed: $isIndexed
    isNotNull: $isNullable
    isPrimaryKey: $isPrimaryKey
    isForeignKey: $isForeignKey
    isUnique: $isUnique
    enumValues: $enumValues
    foreignKey: $foreignKey
}''';
  }
}
