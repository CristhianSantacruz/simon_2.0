import 'package:flutter/material.dart';
import 'package:simon_final/components/simon/alert_dialog.dart';
import 'package:simon_final/components/simon/text_form_register.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';

import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

class ThirdPage extends StatefulWidget {
  static var formKey = GlobalKey<FormState>();
  static var emailController = TextEditingController();
  //static var phoneController = TextEditingController();
  static var confirmEmailController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();
  static TextEditingController confirmPasswordController =TextEditingController();
  final bool? isCreateProfile;
  const ThirdPage({super.key,this.isCreateProfile = false});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;

  bool viewPassword = true;
  bool viewConfirmPassword = true;
  void checkPassword(String password) {
    setState(() {
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasLowercase = password.contains(RegExp(r'[a-z]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showEmailAlert(context);
    });

    checkPassword(ThirdPage.passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 16),
            child: Text(
              widget.isCreateProfile == true ? 'Información de cuenta del perfil' : 'Información de cuenta',
              style: primarytextStyle(size: 26),
            ),
          ),
          thirdForm(ThirdPage.formKey),
        ],
      ),
    );
  }

  void showEmailAlert(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const CustomAlertDialog(
            title: "Importante",
            content:
                "Ingrese un correo válido y accesible, ya que será clave en su proceso de impugnación.",
            iconData: Icons.email,
          );
        });
  }

  Form thirdForm(GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormFieldRegister(
              label: "Correo Electronico",
              icon: const Icon(
                Icons.email,
                color: 
                     simon_finalPrimaryColor,
              ),
              controller: ThirdPage.emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'El correo es requerido';
                } else if (!emailValidate.hasMatch(value)) {
                  return 'Por favor ingrese un Email valido';
                }
                return null;
              }),
          15.height,
          TextFormFieldRegister(
              label: "Confirmar Correo Electronico",
              icon: const Icon(
                Icons.email,
                color: simon_finalPrimaryColor,
              ),
              controller: ThirdPage.confirmEmailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Confirmar el correo es requerido';
                } else if (!emailValidate.hasMatch(value)) {
                  return 'Por favor ingrese un Email valido';
                } else if (value != ThirdPage.emailController.text) {
                  return 'Los correos no coinciden';
                }
                return null;
              }),
          15.height,
          
         !( widget.isCreateProfile == true) ? TextFormField(
            controller: ThirdPage.passwordController,
            obscureText: viewPassword,
            onChanged: checkPassword,
            style: TextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
            decoration: InputDecoration(
              fillColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
              prefixIcon: const Icon(
                Icons.lock,
                color: simon_finalPrimaryColor,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    viewPassword = !viewPassword;
                  });
                },
                icon: viewPassword
                    ? const Icon(
                        Icons.visibility,
                        color: simon_finalPrimaryColor,
                      )
                    : const Icon(
                        Icons.visibility_off,
                        color: simon_finalPrimaryColor,
                      ),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
              hintText: 'Contraseña',
              hintStyle: TextStyle(color: appStore.isDarkMode ? scaffoldLightColor : resendColor),
              filled: true,
         
            ),
            validator: (password) {
              if (password == null || password.isEmpty) {
                return 'La contraseña no puede estar vacía';
              }
              if (!RegExp(r'^(?=.*[A-Z])').hasMatch(password)) {
                return 'Debe contener al menos una letra mayúscula';
              }
              if (!RegExp(r'^(?=.*[0-9])').hasMatch(password)) {
                return 'Debe contener al menos un número';
              }
              if (password.length < 8) {
                return 'Debe tener al menos 8 caracteres';
              }
              if (password != ThirdPage.confirmPasswordController.text) {
                return 'Las contraseñas no coinciden';
              }

              return null; // Si pasa todas las validaciones
            },
          ) : const SizedBox.shrink(),
          const SizedBox(height: 16),
          !(widget.isCreateProfile == true) ? TextFormField(
            validator: (value){
              if(value == null || value.isEmpty){
                return 'Confirmar contraseña es requerida';
              }
              if(value != ThirdPage.passwordController.text){
                return 'Las contraseñas no coinciden';
              }
              return null;

            },
            controller: ThirdPage.confirmPasswordController,
            obscureText: viewConfirmPassword,
             style: TextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock,
                color: simon_finalPrimaryColor,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    viewConfirmPassword = !viewConfirmPassword;
                  });
                },
                icon: viewConfirmPassword
                    ? const Icon(
                        Icons.visibility,
                        color: simon_finalPrimaryColor,
                      )
                    : const Icon(
                        Icons.visibility_off,
                        color: simon_finalPrimaryColor,
                      ),
              ),
              hintText: 'Confirmar Contraseña',
              hintStyle: TextStyle(color: appStore.isDarkMode ? scaffoldLightColor : resendColor),
              filled: true,
               fillColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
            ),
          ) : const SizedBox.shrink(),
          const SizedBox(height: 16),
          !(widget.isCreateProfile == true) ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildValidationRow(
                  "Debe contener al menos una letra mayúscula", hasUppercase),
              buildValidationRow("Debe tener al menos 8 caracteres",
                  ThirdPage.passwordController.text.length >= 8),
              buildValidationRow("Debe incluir al menos un número", hasNumber),
            ],
          ) : const SizedBox.shrink(),
          const SizedBox(height: 24),
        
        ],
      ),
    );
  }

  Widget buildValidationRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isValid ? Colors.green : resendColor,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: primarytextStyle(size: 14, weight: FontWeight.w400),
        ),
      ],
    );
  }
}
