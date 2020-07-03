import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart';

import '../constant/constant.dart';
import '../constant/postgres_query.dart';
import '../extension/list_extension.dart';
import '../model/column.dart';
import '../model/foreign_key.dart';
import '../model/schema.dart';
import '../model/sql_connection.dart';
import '../model/table.dart';

class PosgtresIntrospector {
  final PostgreSQLConnection connection;

  PosgtresIntrospector({
    @required SqlConnection sqlConnection,
  })  : assert(sqlConnection != null),
        connection = PostgreSQLConnection(
          sqlConnection.host,
          sqlConnection.port,
          sqlConnection.database,
          username: sqlConnection.username,
          password: sqlConnection.password,
        );

  Future<void> open() => connection.open();

  Future<void> close() => connection.close();

  Future<List<Schema>> getSchemas() async {
    return Future.wait(
      (await _getAllSchemaNames())
          .map((schemaName) async => Schema(
                name: schemaName,
                tables: await _getTables(schemaName),
              ))
          .toList(),
    );
  }

  Future<List<String>> _getAllSchemaNames() async {
    return (await connection.query(kSelectSchemaNamesQuery))
        .map((resultRow) => resultRow.single)
        .toList()
        .cast<String>();
  }

  Future<List<Table>> _getTables(final String schemaName) async {
    final tables = <Table>[];

    final tableNames = await _getAllTableNames(schemaName);

    for (final tableName in tableNames) {
      tables.add(
        Table(
          name: tableName,
          foreignKeys: await _getForeignKeys(
            schemaName,
            tableName,
          ),
          columns: await _getColumns(
            schemaName,
            tableName,
          ),
        ),
      );
    }

    return tables;
  }

  Future<List<String>> _getAllTableNames(final String schemaName) async {
    return (await connection.query(
      kSelectTableNamesQuery.replaceFirst(kSchemaNameJoker, schemaName),
    ))
        .map((resultRow) => resultRow.single)
        .toList()
        .cast<String>();
  }

  Future<List<Column>> _getColumns(
    final String schemaName,
    final String tableName,
  ) async {
    return Future.wait(
      (await connection.mappedResultsQuery(
        kSelectColumnsQuery
            .replaceFirst(kSchemaNameJoker, schemaName)
            .replaceFirst(kTableNameJoker, tableName),
      ))
          .map(
            (resultRow) async => Column(
              name: resultRow[null]['column_name'],
              description: resultRow[null]['description'],
              dartType: _getDartType(resultRow[null]['udt_name']),
              databaseType: resultRow[null]['udt_name'],
              defaultValue: resultRow[null]['column_default'],
              isGenerated: false,
              isIndexed: false,
              isNullable: resultRow[null]['is_nullable'],
              isPrimaryKey: resultRow[null]['is_identity'],
              isUnique: resultRow[null]['is_unique'],
              enumValues: resultRow[null]['enum_values']?.split('|'),
              foreignKey: await _getForeignKey(
                schemaName,
                tableName,
                resultRow[null]['column_name'],
              ),
            ),
          )
          .toList(),
    );
  }

  Future<List<ForeignKey>> _getForeignKeys(
    final String schemaName,
    final String tableName,
  ) async {
    return (await connection.mappedResultsQuery(
      kSelectForeignKeysQuery
          .replaceFirst(kSchemaNameJoker, schemaName)
          .replaceAll(kTableNameJoker, tableName),
    ))
        .map(
          (resultRow) => ForeignKey(
            fromTable: resultRow['pg_class']['from_table'],
            fromColumn: resultRow['pg_attribute']['from_column'],
            toTable: resultRow['pg_class']['to_table'],
            toColumn: resultRow['pg_attribute']['to_column'],
            onDelete: resultRow[null]['on_delete'],
            onUpdate: resultRow[null]['on_update'],
          ),
        )
        .toList()
        .cast<ForeignKey>();
  }

  Future<ForeignKey> _getForeignKey(
    final String schemaName,
    final String tableName,
    final String columnName,
  ) async {
    return (await connection.mappedResultsQuery(
      kSelectForeignKeyQuery
          .replaceAll(kSchemaNameJoker, schemaName)
          .replaceAll(kTableNameJoker, tableName)
          .replaceAll(kColumnJoker, columnName),
    ))
        .map(
          (resultRow) => ForeignKey(
            fromTable: resultRow['pg_class']['from_table'],
            fromColumn: resultRow['pg_attribute']['from_column'],
            toTable: resultRow['pg_class']['to_table'],
            toColumn: resultRow['pg_attribute']['to_column'],
            onDelete: resultRow[null]['on_delete'],
            onUpdate: resultRow[null]['on_update'],
          ),
        )
        .toList()
        .cast<ForeignKey>()
        .firstOrNull;
  }

  String _getDartType(String postgresSqlType) {
    switch (postgresSqlType) {
      case 'bytea':
        return 'List<int>';
      case 'abstime':
      case 'anyarray':
      case 'bit':
      case 'bpchar':
      case '"char"':
      case 'character':
      case 'character varying':
      case 'cidr':
      case 'circle':
      case 'inet':
      case 'interval':
      case 'json':
      case 'jsonb':
      case 'line':
      case 'lseg':
      case 'macaddr':
      case 'name':
      case 'oid':
      case 'path':
      case 'pg_dependencies':
      case 'pg_lsn':
      case 'pg_ndistinct':
      case 'pg_node_tree':
      case 'point':
      case 'polygon':
      case 'regproc':
      case 'regtype':
      case 'text':
      case 'tsquery':
      case 'tsvector':
      case 'txid_snapshot':
      case 'uuid':
      case 'varchar':
      case 'xid':
      case 'xml':
        return 'String';
      case 'ARRAY':
      case 'bigint':
      case 'int2':
      case 'int4':
      case 'int8':
      case 'integer':
      case 'smallint':
        return 'int';
      case 'boolean':
        return 'bool';
      case 'box':
      case 'double precision':
      case 'float4':
      case 'float8':
      case 'money':
      case 'numeric':
      case 'real':
        return 'double';
      case 'date':
      case 'time':
      case 'timetz':
      case 'time with time zone':
      case 'time without time zone':
      case 'timestamp':
      case 'timestamptz':
      case 'timestamp with time zone':
      case 'timestamp without time zone':
        return 'DateTime';
      default:
        return postgresSqlType;
    }
  }
}
