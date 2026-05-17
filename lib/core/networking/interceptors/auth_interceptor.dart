import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // In production, fetch this from Firebase Auth or secure storage
    const String? token = "mock_jwt_token_for_development";
    
    // ignore: dead_code
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized globally here (e.g., trigger logout)
    if (err.response?.statusCode == 401) {
      // Trigger logout or token refresh
    }
    super.onError(err, handler);
  }
}
