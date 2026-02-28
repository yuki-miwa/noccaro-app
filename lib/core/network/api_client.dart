import 'package:dio/dio.dart';

import '../env/app_env.dart';

class ApiClient {
  ApiClient({required String? bearerToken})
    : dio = Dio(
        BaseOptions(
          baseUrl: AppEnv.apiBaseUrl,
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          headers: {
            if (bearerToken != null && bearerToken.isNotEmpty)
              'Authorization': 'Bearer $bearerToken',
          },
        ),
      );

  final Dio dio;
}
