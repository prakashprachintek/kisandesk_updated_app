import 'package:get/get.dart';
import 'package:mainproject1/views/redundant%20files/login_page.dart';

part 'app_routes.dart';


class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () =>  LoginPage(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.HOME,
      page: () =>  LoginPage(),
      transition: Transition.fadeIn,
    ),
  ];
}
