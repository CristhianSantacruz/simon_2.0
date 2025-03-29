import 'package:flutter/material.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';

class DropdownTextFieldRegister extends StatelessWidget {
  final List<DropdownMenuItem<String>> items;
  final String hintText;
  final TextEditingController controller;
  final Icon? icon;
  final String? value;
  final bool? enabledDropdown;
  final Function(String?)? onChangedDropdown;

  const DropdownTextFieldRegister({
    super.key,
    required this.items,
    required this.hintText,
    required this.controller,
    this.icon,
    this.value,
    this.enabledDropdown,
    this.onChangedDropdown,

  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: enabledDropdown == false,
      child: DropdownButtonFormField<String>(
         value:  value,
         dropdownColor: appStore.isDarkMode ?scaffoldSecondaryDark : Colors.white, 
         style: TextStyle(color: appStore.isDarkMode ? Colors.white : enabledDropdown == false ? resendColor : Colors.black,fontSize: 16),
         decoration: InputDecoration(
          //labelText: hintText,
          filled: true,
          fillColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
          hintText: hintText,
          hintStyle: TextStyle(
          fontSize: 16,
          color: appStore.isDarkMode ? Colors.white : enabledDropdown == false ? resendColor : Colors.black, // Color del hint
      ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
            borderSide: BorderSide(color: enabledDropdown == false ? resendColor : Colors.black, width: 1),
          ),
          
          prefixIcon: icon ?? null,
        ),
        items: items,
        onChanged: onChangedDropdown ?? (value) {
          controller.text = value ?? '';
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$hintText es requerido';
          }
          return null;
        },
       
      ),
    );
  }
}
