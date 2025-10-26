import 'package:dio/dio.dart';
import 'package:mainproject1/src/core/constant/api_constants.dart';
import 'api_error_handler.dart';

class ApiClient {
  late Dio dio;
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.BASE_URL,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        String? customBaseUrl,
      }) async {
    try {
      final Response response = await dio.get(
        _resolveUrl(path, customBaseUrl),
        queryParameters: query,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleError(e);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? query,
        Map<String, dynamic>? headers,
        String? customBaseUrl,
      }) async {
    try {
      final Response response = await dio.post(
        _resolveUrl(path, customBaseUrl),
        data: data,
        queryParameters: query,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ApiErrorHandler.handleError(e);
    } catch (e) {
      throw ApiErrorHandler.handleError(e);
    }
  }



  /// Helper: Resolve full URL dynamically
  String _resolveUrl(String path, String? customBaseUrl) {
    if (customBaseUrl != null && customBaseUrl.isNotEmpty) {
      return '$customBaseUrl$path';
    }
    return '${dio.options.baseUrl}$path';
  }
}
