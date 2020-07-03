import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

final kDartFormatter = DartFormatter();

final kDartEmitter = DartEmitter(
  Allocator(),
  true,
  true,
);

const kAqueductPackage = 'package:aqueduct/aqueduct.dart';

const kDatabaseJoker = '{{database_table}}';

const kSchemaNameJoker = '{{schema_table}}';

const kTableNameJoker = '{{table_table}}';

const kColumnJoker = '{{column_table}}';
