import 'package:flutter/material.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/utils/colors.dart';

class CustomDropdownButtonFormField<T> extends StatelessWidget {
  final FocusNode? focusNode;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;
  final String hintText;
  final bool? enabled;

  const CustomDropdownButtonFormField({
    super.key,
    this.focusNode,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    required this.hintText,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      style: TextStyle(color:  appStore.isDarkMode ? Colors.white : Colors.black),
      dropdownColor:  appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
      focusNode: focusNode,
      value: value,
      decoration: InputDecoration(
    hintStyle: TextStyle(
          fontSize: 16,
          color: appStore.isDarkMode ? Colors.white : enabled == false ? resendColor : Colors.black), // Color del hint
        hintText: hintText,
        fillColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
        filled: true,
        enabledBorder: enabled == false
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: resendColor, width: 1),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: borderColor, width: 1),
              ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.red[300]!, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: simon_finalPrimaryColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: simon_finalPrimaryColor, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: resendColor, width: 1),
        ),
      ),
      items: items,
      onChanged: enabled == true ? onChanged : null,
      validator: validator,
    );
  }
}
