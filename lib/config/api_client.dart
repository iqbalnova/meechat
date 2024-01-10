import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio = Dio();
  static final ApiClient _singleton = ApiClient._internal();
  final storage = const FlutterSecureStorage();

  factory ApiClient() {
    return _singleton;
  }

  ApiClient._internal() {
    _dio.options.baseUrl = const String.fromEnvironment("BASE_URL");
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = "Bearer $token";
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final token = await storage.read(key: 'token');

        if (error.response?.statusCode != 401 ||
            error.response?.data['error'] == null ||
            token == null) {
          return handler.next(error);
        }

        // TODO: Handle Refresh Token
        // RequestOptions origin = error.requestOptions;

        // try {
        //   await GetIt.instance<AuthServices>().refreshSession();

        //   Response response = await _dio.fetch(origin);
        //   return handler.resolve(response);
        // } on DioException catch (error) {
        //   handler.reject(error);
        // }
      },
    ));
  }

  Future<Response> apiPost(String endPoint, {dynamic data}) async {
    return _dio.post(endPoint, data: data);
  }

  Future<Response> apiGet(String endPoint, {dynamic data}) async {
    return _dio.get(endPoint, queryParameters: data);
  }

  Future<Response> apiDelete(String endPoint, {dynamic data}) async {
    return _dio.delete(endPoint, data: data);
  }

  Future<Response> apiPut(String endPoint, {dynamic data}) async {
    return _dio.put(endPoint, data: data);
  }

  Future<Response> apiPatch(String endPoint, {dynamic data}) async {
    return _dio.patch(endPoint, data: data);
  }
}
