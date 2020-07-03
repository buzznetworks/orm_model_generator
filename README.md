A ORM model generator (currentlly supports only Aqueduct and PostgreSQL.

## Usage

A simple usage example:

```dart
import 'package:orm_model_generator/orm_model_generator.dart';

void main() async {
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

```

## Todo

- Add CLI Tool
- Add Flutter Website

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/buzznetworks/orm_model_generator/issues/new
