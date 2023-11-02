import 'dart:developer' as developer;

class Log {
  Log._();

  static void print(String value, {StackTrace? stackTrace}) {
    developer.log(value, name: 'LOG', stackTrace: stackTrace);
  }

  static Object? inspect(Object? object) {
    return developer.inspect(object);
  }
}
