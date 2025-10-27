import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodel/user_viewmodel.dart';

class UserView extends StatelessWidget {
  final controller = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error.value));
        } else {
          return ListView.builder(
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.loadUsers,
        child: const Icon(Icons.download),
      ),
    );
  }
}
