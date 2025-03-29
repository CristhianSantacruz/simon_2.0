import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/utils/common.dart';

class TextFormFieldRegister extends StatelessWidget {
  final Icon? icon;
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final bool? showMaxLength;
  final int? maxLength;
  
  const TextFormFieldRegister({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.icon,
    this.inputFormatters,
    this.textInputAction,
    this.textCapitalization,
    this.showMaxLength,
    this.maxLength,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: showMaxLength ?? false ? maxLength  : null,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      textInputAction: TextInputAction.next,
      style:TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
      decoration: inputDecoration(context, labelText: label,prefixIcon: icon),
      validator: validator,
       inputFormatters: inputFormatters ?? [],
    );
  }
}
