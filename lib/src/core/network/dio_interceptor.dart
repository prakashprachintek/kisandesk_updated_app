import 'package:dio/dio.dart';

class AppInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Example: Add Bearer token
    options.headers['Authorization'] = 'Bearer YOUR_TOKEN';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // Example: Handle 401/500 errors globally
    if (err.response?.statusCode == 401) {
      // handle token refresh or logout
    }
    super.onError(err, handler);
  }
}
