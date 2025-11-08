import 'package:flutter/material.dart';

class CustomDropdown<T> extends FormField<T> {
  final String? title;
  final bool isMandatory;
  final String? hint;
  final List<T> items;
  final String Function(T) itemLabel;
  final Widget? prefixIcon;

  CustomDropdown({
    Key? key,
    this.title,
    this.isMandatory = false,
    this.hint,
    required this.items,
    required this.itemLabel,
    T? initialValue,
    this.prefixIcon,
    String? Function(T?)? validator,
    void Function(T?)? onChanged,
    bool autovalidate = false,
  }) : super(
    key: key,
    initialValue: initialValue,
    validator: validator ??
            (value) {
          if (isMandatory && value == null) return 'This field is required';
          return null;
        },
    autovalidateMode: autovalidate
        ? AutovalidateMode.always
        : AutovalidateMode.disabled,
    builder: (FormFieldState<T> state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            RichText(
              text: TextSpan(
                text: title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: isMandatory
                    ? [
                  const TextSpan(
                      text: ' *', style: TextStyle(color: Colors.red))
                ]
                    : [],
              ),
            ),
          if (title != null) const SizedBox(height: 8),
          DropdownMenu<T>(
            initialSelection: state.value,
            leadingIcon: prefixIcon,
            hintText: hint,

            dropdownMenuEntries: items
                .map((e) => DropdownMenuEntry<T>(
              value: e,
              label: itemLabel(e),
            ))
                .toList(),
            onSelected: (val) {
              state.didChange(val);
              if (onChanged != null) onChanged(val);
            },
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                state.errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      );
    },
  );
}
