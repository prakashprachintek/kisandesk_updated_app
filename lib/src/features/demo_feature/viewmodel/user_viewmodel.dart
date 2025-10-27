import 'package:get/get.dart';
import 'package:mainproject1/src/features/demo_feature/data/user_model.dart';
import '../data/repository/user_repository.dart';

class UserViewModel extends GetxController {
  final UserRepository _repo;
  UserViewModel(this._repo);

  var users = <UserModel>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  Future<void> loadUsers() async {
    try {
      isLoading(true);
      error('');
      users.value = await _repo.fetchUsers();
    } catch (e) {
      error('Failed to load users');
    } finally {
      isLoading(false);
    }
  }
}
