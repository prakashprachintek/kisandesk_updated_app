import 'package:get/get.dart';
import 'package:mainproject1/src/features/auth/repository/auth_repository.dart';
import 'package:mainproject1/src/features/auth/view_model/login_controller.dart';
import 'package:mainproject1/src/features/demo_feature/data/repository/user_repository.dart';
import 'package:mainproject1/src/features/demo_feature/viewmodel/user_viewmodel.dart';
import '../network/api_client.dart';

class DependencyInjection {
  static Future<void> init() async {
    // Network client
    Get.lazyPut(() => ApiClient());

    // Repository layer
    Get.lazyPut(() => UserRepository(Get.find<ApiClient>()));

    // Repository layer
    Get.lazyPut(() => AuthRepository(Get.find<ApiClient>()));

    // ViewModel layer
    Get.lazyPut(() => LoginController(Get.find<AuthRepository>()));
  }
}
