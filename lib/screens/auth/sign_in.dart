import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/screens/auth/new_sign_in.dart';
import 'package:simon_final/screens/auth/register_page/new_register_page.dart';
import 'package:simon_final/services/login_register_services.dart';
import 'package:simon_final/utils/images.dart';
import 'package:simon_final/utils/app_routes.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/common.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool isChecked = false;

  final _loginService = LoginService();

  Future<void> login(
      String email, String password, UserProvider userProvider) async {
    debugPrint("Datos del Login: ${email} ${password}");
    final response = await _loginService.login(email, password, userProvider);
    if (response['success'] == true) {
      //inicio exitoso

      MessagesToast.showMessageSuccess("Inicio de Sesion Exitoso");
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      }

      /*  final popUpData = {
        "id": 1,
        "name": "Pop up navideño",
        "redirect": "Si",
        "date_from": "2024-12-05",
        "date_to": "2024-12-14",
        "monday": 0,
        "tuesday": 1,
        "wednesday": 0,
        "thursday": 1,
        "friday": 0,
        "saturday": 1,
        "sunday": 1,
        "created_at": "2024-12-05T14:39:37.000000Z",
        "updated_at": "2024-12-05T14:39:37.000000Z",
        "deleted_at": null,
        "photo_url":
            "http://simon_final.devnarviz.com/public/storage/2/6751bb1cd13e2_EMOV.jpeg"
      };

      final popModel = PopUpModel.fromJson(popUpData);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopUpAfterLogin(photoUrl: popModel.photoUrl);
        },
      );*/
    } else {
      MessagesToast.showMessageError(response['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final size = MediaQuery.of(context).size;
    return Observer(builder: (context) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : white_color,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter, // Centrado horizontalmente, pegado arriba
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 5), // Ajusta la altura según quieras
                child: Image.asset(
                  legal_2_png,
                  height: 340,
                  width: 340,
                  fit: BoxFit.contain, // Mejor ajuste para logos
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: 22,
                  right: 22,
                  top: size.height * 0.28), // Padding responsivo
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "Bienvenido de nuevo",
                      style: TextStyle(
                          color:
                              appStore.isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          height: 1.5),
                    ),
                  ),
                  const Center(
                      child: Text(
                    "Inicia Sesión en tu cuenta",
                    style: TextStyle(
                        color: resendColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        height: 1.1),
                  )),
                  20.height,
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: TextStyle(
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                          controller: emailController,
                          decoration: inputDecoration(context,
                              labelText: 'Correo electrónico',
                              prefixIcon: const Icon(
                                Icons.email,
                                color: simon_finalPrimaryColor,
                              )),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Correo Electronico Requerido';
                            } else if (!emailValidate.hasMatch(value)) {
                              return 'Por favor ingresa Email/Usuario';
                            }
                            return null;
                          },
                        ),
                        20.height,
                        TextFormField(
                          controller: passwordController,
                          style: TextStyle(
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: simon_finalPrimaryColor,
                            ),
                            filled: true,
                            fillColor: appStore.isDarkMode
                                ? scaffoldSecondaryDark
                                : Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(DEFAULT_RADIUS)),
                            labelText: 'Contraseña',
                            labelStyle: TextStyle(
                                color: appStore.isDarkMode
                                    ? scaffoldLightColor
                                    : scaffoldDarkColor),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureText,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Contraseña es Requerida';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) async {
                            await login(
                                emailController.text, value, userProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                  10.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          /*SizedBox(
                            width: 30,
                            height: 30,
                            child: Checkbox(
                              activeColor: simon_finalPrimaryColor,
                              shape: StadiumBorder(),
                              value: isChecked,
                              onChanged: (value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                          ),*/
                          Text('',
                              style: TextStyle(
                                  color: appStore.isDarkMode
                                      ? scaffoldLightColor
                                      : scaffoldDarkColor)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                         // ForgotPasswordScreen().launch(context);
                         //_launchURL("https://simon_final.devnarviz.com/password/reset");
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const NewSignIn()));
                        },
                        child: const Text('¿Olvidastes tu contraseña?',
                            style: TextStyle(
                                color: simon_finalPrimaryColor,
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  10.height,
                  Container(
                    width: double.infinity,
                    child: AppButton(
                        elevation: 0,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            await login(emailController.text,
                                passwordController.text, userProvider);
                          }
                        },
                        color: simon_finalPrimaryColor,
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(DEFAULT_RADIUS)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.login,
                              color: Colors.white,
                              size: 20,
                            ),
                            5.width,
                            Text('Iniciar Sesión',
                                style: primarytextStyle(
                                    color: Colors.white, size: 14)),
                          ],
                        )),
                  ),
                  20.height,
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Aún no tienes cuenta? ',
                          style: TextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NewRegisterScreen()));
                          },
                          child: const Text(
                            'Regístrate aqui',
                            style: TextStyle(
                              color: simon_finalPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
      );
    });
  }
  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'No se pudo abrir $url';
    }
  }
}
