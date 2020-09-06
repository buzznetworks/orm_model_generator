import 'package:orm_model_generator/orm_model_generator.dart';

Future<void> main() async {
  final sqlConnection = SqlConnection.postgres(
    database: 'my_db', // default = 'localhost'
    host: 'host', // default = 'postgres'
    port: 5432, // default = 5432
    username: 'username', // default = 'postgres'
    password: 'password', // default = ''
    useSsl: true, // default = true
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
