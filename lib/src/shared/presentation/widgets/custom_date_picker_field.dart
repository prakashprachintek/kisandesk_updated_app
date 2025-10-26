import 'package:flutter/material.dart';

class CustomDatePickerField extends StatefulWidget {
  final TextEditingController? controller;
  final String? title;
  final String? hint;
  final bool isMandatory;
  final String? Function(String?)? validator;
  final void Function(DateTime)? onDateSelected;

  const CustomDatePickerField({
    Key? key,
    this.controller,
    this.title,
    this.hint,
    this.isMandatory = false,
    this.validator,
    this.onDateSelected,
  }) : super(key: key);

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate =
          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      widget.controller?.text = formattedDate;
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          RichText(
            text: TextSpan(
              text: widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              children: widget.isMandatory
                  ? [
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]
                  : [],
            ),
          ),
        if (widget.title != null) const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          readOnly: true,
          validator: widget.validator,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            hintText: widget.hint ?? "Select date",
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ),
      ],
    );
  }
}
