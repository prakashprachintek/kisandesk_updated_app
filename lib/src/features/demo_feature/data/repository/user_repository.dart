import 'package:dio/dio.dart';
import 'package:mainproject1/src/features/demo_feature/data/user_model.dart';
import '../../../../core/network/api_client.dart';

class UserRepository {
  final ApiClient _apiClient;
  UserRepository(this._apiClient);

  Future<List<UserModel>> fetchUsers() async {
    try {
      final Response response = await _apiClient.dio.get('/users');
      return (response.data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
