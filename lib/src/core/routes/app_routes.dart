

import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mainproject1/src/features/auth/view/login_screen.dart';
import 'package:mainproject1/views/other/welcome.dart';

import '../../../views/home/HomePage.dart';

class AppRoutes {
  static const home = '/home';
  static const login = '/login';
  static const welcome = '/welcome';

  static final routes = [
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: welcome, page: () => KisanDeskScreen()),
  ];
}