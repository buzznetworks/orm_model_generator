A ORM model generator (currently supports only Aqueduct and PostgreSQL).

## Usage

A simple usage example:

```dart
import 'package:orm_model_generator/orm_model_generator.dart';

Future<void> main() async {
  final sqlConnection = SqlConnection.postgres(
    database: 'my_db',
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

## Todo

- Add validators
- Add CLI Tool
- Add Flutter website and desktop applications
- Publish to pub

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/buzznetworks/orm_model_generator/issues/new
