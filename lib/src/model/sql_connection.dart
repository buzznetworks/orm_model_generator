import 'package:meta/meta.dart';

class SqlConnection {
  final String host;

  final int port;

  final String database;

  final String username;

  final String password;

  const SqlConnection._({
    @required this.host,
    @required this.port,
    @required this.database,
    @required this.username,
    @required this.password,
  })  : assert(host != null),
        assert(port != null),
        assert(database != null),
        assert(username != null),
        assert(password != null);

  factory SqlConnection.postgres({
    String host,
    int port,
    String database,
    String username,
    String password,
  }) =>
      SqlConnection._(
        host: host ?? 'localhost',
        port: port ?? 5432,
        database: database ?? 'postgres',
        username: username ?? 'postgres',
        password: password ?? '',
      );

  @override
  String toString() {
    return '''SqlConnection{
    host: $host
    port: $port
    database: $database
    user: $username
    password: $password
}''';
  }
}
