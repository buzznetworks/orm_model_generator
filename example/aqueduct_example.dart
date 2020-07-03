import 'package:orm_model_generator/orm_model_generator.dart';

Future<void> main() async {
  final sqlConnection = SqlConnection.postgres(
    database: 'my_bd',
  );

  final postgresIntrospector = PosgtresIntrospector(
    sqlConnection: sqlConnection,
  );

  await postgresIntrospector.open();

  final schemas = await postgresIntrospector.getSchemas();

  for (final schema in schemas) {
    AqueductBuilder.generateOrmModels(schema);
  }

  await postgresIntrospector.close();
}
