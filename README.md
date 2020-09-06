A ORM model generator (currently supports only Aqueduct and PostgreSQL).

## Usage

A simple usage example:

```dart
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
```

### Steps

1. Clone the repository
2. Run `pub get` in the cloned repository
2. Update the SQLConnection parameters with your credentials
3. Run `dart example/aqueduct_example.dart`
4. Get your models in the output folder.

## Todo

- Add validators
- Add CLI Tool
- Add Flutter website and desktop applications
- Publish to pub

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/buzznetworks/orm_model_generator/issues/new
