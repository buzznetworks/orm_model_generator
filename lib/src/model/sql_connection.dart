import 'package:meta/meta.dart';

class SqlConnection {
  final String host;

  final int port;

  final String database;

  final String username;

  final String password;

  final bool useSsl;

  const SqlConnection._({
    @required this.host,
    @required this.port,
    @required this.database,
    @required this.username,
    @required this.password,
    @required this.useSsl,
  })  : assert(host != null),
        assert(port != null),
        assert(database != null),
        assert(username != null),
        assert(password != null),
        assert(useSsl != null);

  factory SqlConnection.postgres({
    String host = 'localhost',
    int port = 5432,
    String database = 'postgres',
    String username = 'postgres',
    String password = '',
    bool useSsl = true,
  }) =>
      SqlConnection._(
        host: host,
        port: port,
        database: database,
        username: username,
        password: password,
        useSsl: useSsl,
      );

  @override
  String toString() {
    return '''SqlConnection{
    host: $host
    port: $port
    database: $database
    user: $username
    password: $password
    useSSL: $useSsl
}''';
  }
}
