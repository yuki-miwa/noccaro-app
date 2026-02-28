import 'package:noccaro_app/core/storage/token_storage.dart';

class InMemoryTokenStorage extends TokenStorage {
  InMemoryTokenStorage() : super();

  String? _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<String?> readToken() async {
    return _token;
  }

  @override
  Future<void> writeToken(String token) async {
    _token = token;
  }
}
