import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
enum TextFieldType {
  none,
  mobileNumber,
  pinCode,
  name,
  digitsOnly,
}
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? title;
  final bool obscureText;
  final bool readOnly;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final bool isMandatory;
  final int? maxLength;
  final TextFieldType fieldType;

  const CustomTextField({
    Key? key,
    this.controller,
    this.label,
    this.hint,
    this.maxLength,
    this.title,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.isMandatory = false,
    this.fieldType = TextFieldType.none,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                color: Colors.black,
              ),
              children: isMandatory
                  ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]
                  : [],
            ),
          ),
        if (title != null) const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
          onChanged: onChanged,
          maxLength: maxLength,
          inputFormatters: _getInputFormatters(),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black26),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
               BorderSide(color: Theme.of(context).primaryColor.withAlpha(110), width: 1.0),
            ),
            fillColor: readOnly ? Colors.grey.shade100 : null,
            filled: readOnly,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
              const BorderSide(color: Colors.red, width: 2.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
              const BorderSide(color: Colors.red, width: 2.0),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
        ),
      ],
    );
  }
  List<TextInputFormatter> _getInputFormatters() {
    switch (fieldType) {
      case TextFieldType.mobileNumber:
        return [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)];
      case TextFieldType.pinCode:
        return [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)];
      case TextFieldType.name:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          LengthLimitingTextInputFormatter(maxLength ?? 50),
        ];
      case TextFieldType.digitsOnly:
        return [FilteringTextInputFormatter.digitsOnly];
      case TextFieldType.none:
        return [];
    }
  }
}
