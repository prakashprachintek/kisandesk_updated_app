import 'package:flutter/material.dart';
import 'package:mainproject1/src/shared/presentation/widgets/buttons/arrow_back_button_widget.dart';

class ArrowBackButtonTitleWidget extends StatelessWidget {
  final Function()? callback;
  final String title;
  final Color? iconColor;
  final double? fontSize;

  const ArrowBackButtonTitleWidget(
      {super.key, this.callback, this.iconColor, required this.title,  this.fontSize});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyleLarge =
        Theme.of(context).textTheme.titleMedium!.copyWith(fontSize:fontSize);

    return Row(
      children: [
        ArrowBackButtonWidget(
          callback: callback,
          iconColor: iconColor,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          title,
          style: textStyleLarge,
        )
      ],
    );
  }
}
