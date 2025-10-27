import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:mainproject1/src/core/style/colors.dart';

class AppLoader extends StatelessWidget {
  final Color? iconColor;
  final String? title;

  const AppLoader({
    super.key,
    this.iconColor,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = context.theme.textTheme;
    TextStyle textStyle = textTheme.bodySmall!.copyWith(color: AppColors.textPrimary);
    return Center(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 20),
              Text(
                title == null ? 'Loading...' : title!,
                style: textStyle,
              ),
            ],
          )),
    );
  }
}


class FieldCirularLoader extends StatelessWidget {
  const FieldCirularLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        height: 10,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            strokeWidth: 6.0,
            color: Colors.green,
          ),
        ));
  }
}
