import 'package:flutter/material.dart';

class TextFormFieldCustom extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final int? valueKey;
  final FormFieldValidator<String>? validator;
  final Icon? prefixIcon;
  final bool? obscureText;
  final Widget? suffixIcon;

  const TextFormFieldCustom({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.valueKey,
    this.validator,
    this.prefixIcon,
    this.obscureText,
    this.suffixIcon,
  });

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '$labelText tidak boleh kosong';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        TextFormField(
          key: valueKey != null ? ValueKey(valueKey) : null,
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            focusColor: const Color(0xFF7965C1),
          ),
          validator: (value) {
            final error = _defaultValidator(value);
            if (error != null) return error;

            if (validator != null) {
              return validator!(value);
            }

            return null;
          },
        ),
      ],
    );
  }
}
