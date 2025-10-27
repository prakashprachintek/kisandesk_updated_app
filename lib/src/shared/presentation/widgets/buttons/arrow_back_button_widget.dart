import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mainproject1/src/core/constant/image_path_constant.dart';
class ArrowBackButtonWidget extends StatelessWidget {
  final Function()? callback;
  final Color? iconColor;

  const ArrowBackButtonWidget({super.key, this.callback, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: IconButton(
        onPressed: () {
          callback?.call();
          Navigator.pop(context);
        },
        constraints: const BoxConstraints(),
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
            ImagePaths.arrowBackSvg
        ),
      ),
    );
  }
}
