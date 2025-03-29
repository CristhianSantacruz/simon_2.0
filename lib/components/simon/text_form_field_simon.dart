import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';

class TextFormFieldSimon extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;
  final Color? fillColor;
  final bool? enabled;
  final Widget? suffixIcon;
  final bool showInfoIcon;
  final String infoMessage;
  final bool moreAjusted;
  final bool isRequired;
  final bool? isReadOnly;
  final Function()? onTapSimon;
  final int? maxLength;
  final void Function(String)? onChanged;
  final bool? showMaxLength;

  const TextFormFieldSimon({
    required this.controller,
    this.hintText,
    this.fillColor,
    this.icon,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization,
    this.onFieldSubmitted,
    this.focusNode,
    this.enabled,
    this.suffixIcon,
    this.showInfoIcon = false,
    this.infoMessage = "Información sobre este campo",
    this.moreAjusted = false,
    this.isRequired = false,
    this.isReadOnly,
    this.onChanged,
    this.onTapSimon,
    this.showMaxLength,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment
          .centerRight, // Asegura que el ícono esté alineado a la derecha
      children: [
        TextFormField(
          maxLength: showMaxLength ?? false ? maxLength : null,
          style: TextStyle(
              color: appStore.isDarkMode ? Colors.white : Colors.black),
          onTap: onTapSimon ?? () {},
          onChanged: onChanged ?? (value) {},
          readOnly: isReadOnly ?? false,
          enabled: enabled ?? true,
          focusNode: focusNode ?? FocusNode(),
          onFieldSubmitted: onFieldSubmitted ?? (value) {},
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          keyboardType: keyboardType ?? TextInputType.text,
          controller: controller,
          validator: validator ?? (!isRequired ? defaultValidator : null),
          inputFormatters: inputFormatters ?? [],
          decoration: InputDecoration(
            hintStyle: TextStyle(
                color: appStore.isDarkMode ? resendColor : resendColor),
            contentPadding: moreAjusted
                ? const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                : null,
            suffixIcon:
                suffixIcon, // Permite ícono de usuario, si se proporciona
            prefixIcon: icon != null
                ? Icon(icon, color: simon_finalPrimaryColor)
                : null,
            fillColor: fillColor ?? (appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white),
            filled: true,
            hintText: hintText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
              borderSide: const BorderSide(color: borderColor, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
              borderSide: const BorderSide(color: simonNaranja, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
              borderSide:
                  const BorderSide(color: simon_finalPrimaryColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
              borderSide:
                  const BorderSide(color: simon_finalPrimaryColor, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
              borderSide: const BorderSide(color: resendColor, width: 1),
            ),
          ),
        ),
        if (showInfoIcon && suffixIcon == null)
          Positioned(
            right: 10, // Espaciado a la derecha del `TextFormField`
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => CustomInfoAlert(
                      title: "Información", infoMessage: infoMessage),
                );
              },
              child: Icon(Icons.info, color: appStore.isDarkMode ? Colors.white : Colors.black),
            ),
          ),
      ],
    );
  }
}

class CustomInfoAlert extends StatelessWidget {
  const CustomInfoAlert({
    super.key,
    required this.title,
    required this.infoMessage,
    this.imageUrl,
    this.withImage,
  });

  final String infoMessage;
  final String title;
  final String? imageUrl;
  final bool? withImage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
      titlePadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
      ),
      title: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: simon_finalPrimaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(DEFAULT_RADIUS),
              topRight: Radius.circular(DEFAULT_RADIUS),
            ),
          ),
          child: Text(
            title,
            style: primaryTextStyle(size: 15, color: Colors.white),
          )),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(textAlign: TextAlign.justify, infoMessage,style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black87),),
          this.withImage == true
              ? Container(
                  width: double
                      .infinity, // O usa un ancho más pequeño si prefieres
                  height: 100, // Tamaño fijo de la imagen (ajústalo a tu gusto)
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imageUrl!),
                      // Ajusta para que cubra el espacio de forma adecuada
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: simon_finalPrimaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

String? defaultValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Este campo es obligatorio';
  }
  return null;
}
