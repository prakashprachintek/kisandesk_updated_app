import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:mainproject1/src/core/style/colors.dart';
import 'package:mainproject1/src/shared/presentation/widgets/buttons/custom_button.dart';

class AppBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? body;
  final String okButtonText;
  final String secondaryButtonText;
  final Function()? onTapOkButton;
  final Function()? onTapClose;
  final Function()? onTapSecondaryButton;
  final bool primaryButtonLoading;
  final bool secondaryButtonLoading;
  final bool disableSecondaryButton;
  final bool hideSecondaryButton;
  const AppBottomSheet(
      {super.key,
      this.title,
      this.body,
      this.okButtonText = 'Submit',
      this.secondaryButtonText = 'Cancel',
      this.onTapClose,
      this.onTapOkButton,
      this.onTapSecondaryButton,
      this.primaryButtonLoading = false,
      this.secondaryButtonLoading = false,
      this.disableSecondaryButton = false,
      this.hideSecondaryButton = false});

  @override
  Widget build(BuildContext context) {
    SizedBox space = const SizedBox(
      height: 10,
    );
    TextTheme textTheme = Theme.of(context).textTheme;
    TextStyle mediumTextStyle =
        textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600);
    return BottomSheet(
        dragHandleColor: AppColors.buttonSecondary,
        dragHandleSize: const Size(100, 4),
        showDragHandle: true,
        onClosing: () {
          Navigator.pop(context);
        },
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ).copyWith(bottom: context.mediaQuery.viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: onTapClose,
                      child: const SizedBox(
                        height: 14,
                        child: Icon(
                          Icons.close,
                          size: 22,
                          color: AppColors.buttonSecondary,
                        ),
                      ),
                    )
                  ],
                ),
                if (title != null)
                  Text(
                    title!,
                    style: mediumTextStyle,
                  ),
                if (body != null) body!,
                space,
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onPressed: onTapOkButton!.call(),
                        verticalPadding: 5,
                        isLoading: primaryButtonLoading, label: okButtonText,
                      ),
                    ),
                  ],
                ),
                if(hideSecondaryButton)...[
                  space,
                  space,
                ],

                if (!hideSecondaryButton) ...{
                  space,
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          onPressed: onTapSecondaryButton!.call(),
                          verticalPadding: 5,
                          isLoading: secondaryButtonLoading, label: 'cancel',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  )
                }
              ],
            ),
          );
        });
  }
}
