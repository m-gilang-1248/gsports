import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  http.Client get httpClient => http.Client();
}
