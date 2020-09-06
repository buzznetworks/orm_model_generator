import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:recase/recase.dart';

import '../constant/constant.dart';
import '../extension/string_extension.dart';
import '../model/column.dart';
import '../model/foreign_key.dart';
import '../model/schema.dart';
import '../model/table.dart';

class AqueductBuilder {
  static String _currentSchemaName;

  static String _currentTableName;

  static void generateOrmModels(Schema schema) async {
    await Directory('output/${schema.name.snakeCase}').create(recursive: true);

    _currentSchemaName = schema.name;

    for (final table in schema.tables) {
      _currentTableName = table.name;

      await _generateOrmModel(table);
    }
  }

  static Future<void> _generateOrmModel(final Table table) async {
    final pascalCaseTableName = table.name.pascalCase;

    final fields = table.columns
        .map((column) => column.isForeignKey
            ? _generateForeignKeyField(column.foreignKey)
            : _generateColumnField(column))
        .toList()
          ..addAll(
            table.foreignKeys
                .where((foreignKey) => foreignKey.toTable == table.name)
                .map((foreignKey) => _generateForeignKeyField(foreignKey))
                .toList(),
          );

    final library = Library(
      (l) => l
        ..body.addAll(
          <Spec>[
            Class(
              (c) => c
                ..name = pascalCaseTableName
                ..extend = TypeReference(
                  (t) => t
                    ..symbol = 'ManagedObject'
                    ..types.add(refer('_$pascalCaseTableName')),
                )
                ..implements.add(refer('_$pascalCaseTableName')),
            ),
            Class(
              (c) => c
                ..name = '_$pascalCaseTableName'
                ..annotations.add(
                  InvokeExpression.newOf(
                    refer('Table', kAqueductPackage),
                    const <Expression>[],
                    <String, Expression>{
                      'name': literalString(table.name),
                    },
                    const <Reference>[],
                  ),
                )
                ..fields.addAll(fields),
            ),
          ],
        ),
    );

    var dartCode = kDartFormatter.format('${library.accept(kDartEmitter)}');

    dartCode = dartCode.replaceAllMapped(
      RegExp(r"@Relate\('(#.+?)'\)"),
      (match) => '@Relate(${match.group(1)})',
    );

    File('output/$_currentSchemaName/${table.name.snakeCase}.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        dartCode,
      );
  }

  static Field _generateColumnField(final Column column) {
    if (column.isEnum) {
      _generateEnumeration(column.dartType, column.enumValues);
    }
    return Field(
      (f) => f
        ..name = column.name.camelCase
        ..type = column.isEnum
            ? refer(column.dartType.pascalCase,
                './${column.dartType.snakeCase}.dart')
            : refer(column.dartType)
        ..annotations.add(
          InvokeExpression.newOf(
            refer('Column', kAqueductPackage),
            const <Expression>[],
            <String, Expression>{
              if (column.isPrimaryKey)
                'primaryKey': literalBool(column.isPrimaryKey),
              if (column.isNullable) 'nullable': literalBool(column.isNullable),
              if (column.defaultValue != null)
                'defaultValue': literalString(column.defaultValue),
              if (column.isUnique) 'unique': literalBool(column.isUnique),
              if (column.isIndexed) 'indexed': literalBool(column.isIndexed),
              if (column.isGenerated)
                'autoincrement': literalBool(column.isGenerated),
            },
            const <Reference>[],
          ),
        ),
    );
  }

// TODO(ilefebvre): Add https://aqueduct.io/docs/db/modeling_data/#example-hierarchical-relationships-self-referencing
  static Field _generateForeignKeyField(
    final ForeignKey foreignKey,
  ) {
    return Field(
      (f) => f
        ..name = foreignKey.fromTable == _currentTableName
            ? foreignKey.fromColumn.replaceAll(RegExp(r'_id$'), '').camelCase
            : foreignKey.fromTable.camelCase.plural
        ..type = foreignKey.fromTable == _currentTableName
            ? refer(
                foreignKey.toTable.pascalCase,
                './${foreignKey.toTable.snakeCase}.dart',
              )
            : refer(
                'ManagedSet<${foreignKey.fromTable.pascalCase}>',
                './${foreignKey.fromTable.snakeCase}.dart',
              )
        ..annotations.addAll(
          <Expression>[
            if (foreignKey.fromTable == _currentTableName)
              InvokeExpression.newOf(
                refer('Relate', kAqueductPackage),
                <Expression>[
                  literalString('#${foreignKey.fromTable.camelCase.plural}'),
                ],
                const <String, Expression>{},
                const <Reference>[],
              ),
          ],
        ),
    );
  }

  static void _generateEnumeration(
    final String enumName,
    final List<String> values,
  ) {
    final dartCode = kDartFormatter.format(
      'enum ${enumName.pascalCase} { ${values.map((value) => value.camelCase).join(',')}, }',
    );

    File('output/$_currentSchemaName/${enumName.snakeCase}.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        dartCode,
      );
  }
}
