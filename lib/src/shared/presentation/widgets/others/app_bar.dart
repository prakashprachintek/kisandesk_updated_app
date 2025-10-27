import 'package:flutter/material.dart';
import 'package:mainproject1/src/shared/presentation/widgets/buttons/arrow_back_button_title.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Function()? callback;
  final String title;
  final Color? iconColor;
  final double elevation;
  final Widget actionWidget;
  final double? fontSize;

  const AppBarWidget(
      {super.key,
      this.callback,
      this.iconColor,
      required this.title,
      this.elevation = 1.0,
      this.fontSize, this.actionWidget = const SizedBox()});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      color: Colors.white,
      child: Row(
        children: [
          const SizedBox(
            width: 20,
          ),
          SizedBox(
            height: kToolbarHeight,
            child: ArrowBackButtonTitleWidget(
                fontSize: fontSize,
                title: title,
                callback: callback,
                iconColor: iconColor),
          ),
          const Spacer(),
          actionWidget,
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
