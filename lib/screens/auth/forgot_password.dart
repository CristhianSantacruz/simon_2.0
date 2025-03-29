import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:simon_final/components/simon/text_form_register.dart';
import 'package:lottie/lottie.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/resend_pin.dart';
import 'package:simon_final/components/text_styles.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/images.dart';
import '../dashboard/dashboard.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
            surfaceTintColor: appStore.isDarkMode
            ? scaffoldDarkColor
            : context.scaffoldBackgroundColor,
        iconTheme: IconThemeData(
            color:
                appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
        backgroundColor: appStore.isDarkMode
            ? scaffoldDarkColor
            : context.scaffoldBackgroundColor,
        //title: Text("Olvidé mi contraseña 🔑"),
        leading: _currentIndex == 0 ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ) : null,
        automaticallyImplyLeading: false,
        ),
        body: PageView.builder(
          // Use the PageController
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          itemCount: 3,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return const Screen1();
              case 1:
                return const Screen2();
              case 2:
                return const Screen3();

              default:
                return const Screen1();
            }
          },
        ),
        bottomNavigationBar: (_currentIndex == 0 || _currentIndex ==2) ?  Container(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            elevation: 0,
            onTap: () async {
              if (_currentIndex == 2) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    Future.delayed(const Duration(seconds: 2), () {
                      Navigator.of(context).pop(); // pop the dialog after 7 seconds
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                    });
                    return AlertDialog(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.all(16),
                      actions: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 15),
                            Container(
                              width: 80,
                              height: 80,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle, color: indicatorColor),
                              child: const Icon(Icons.check, color: Colors.white, size: 28),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Reset Password \nSuccessful!',
                              style: TextStyle(color: simon_finalPrimaryColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Your Password has been successfully changed.',
                              style: secondaryTextStyle(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Lottie.asset(loader_lottie, width: 100, fit: BoxFit.cover),
                          ],
                        ),
                      ],
                    );
                  },
                );
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              }
            },
            color: simon_finalPrimaryColor,
            shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
            child: const Text('Continuar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          ),
        ) : Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
             children: [
              AppButton(
                 elevation: 0,
                 onTap: () {
                   _pageController.previousPage(
                     duration: const Duration(milliseconds: 300),
                     curve: Curves.easeIn,
                   );
                 },
                 color: simon_finalSecondaryColor,
                 shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
                 child: const Text('Anterior',
                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: simon_finalPrimaryColor )),
               ).expand(),
               16.width,
               AppButton(
                 elevation: 0,
                 onTap: () {
                   _pageController.nextPage(
                     duration: const Duration(milliseconds: 300),
                     curve: Curves.easeIn,
                   );
                 },
                 color: simon_finalPrimaryColor,
                 shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
                 child: const Text('Continuar',
                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
               ).expand(),
               
            ],
          ),
        )
      );
    });
  }
}

//Email Sending Screen

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olvidé mi contraseña 🔑',
            style: primarytextStyle(
                color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
          ),
          15.height,
          Text(
              "Introduzca su dirección de correo electrónico. Le enviaremos un código OTP para su verificación en el siguiente paso",
              style: secondarytextStyle(),textAlign: TextAlign.justify,),
          25.height,
          
          TextFormFieldRegister(label: "Correo Electrónico", controller: emailController,),
        ],
      ),
    );
  }
}

// OTP verification screen
class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tienes un correo 📩",
              style: primarytextStyle(
                  color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
            ),
            15.height,
            Text(
                "Hemos enviado el código de verificación OTP a tu dirección de correo electrónico. Comprueba tu correo electrónico e introduce el código a continuación",
                style: secondarytextStyle()),
            15.height,
            Center(
              child: OTPTextField(
                pinLength: 4,
                boxDecoration: BoxDecoration(
                    color: appStore.isDarkMode ? const Color(0xFF1F222A) : simon_finalSecondaryColor,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: simon_finalPrimaryColor, width: 1.0)),
                textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
                fieldWidth: 60,
              ),
            ),
            15.height,
            Center(
                child: Text(
              "¿No ha recibido el correo electrónico?",
              style: TextStyle(color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
            )),
            15.height,
            ResendPin(),
          ],
        ),
      ),
    );
  }
}

// Create new password screen

class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  bool _obscureText = true;
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crear nueva contraseña 🔐',
                style: primarytextStyle(
                    color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
              ),
              15.height,
              Text(
                  "Introduzca su nueva contraseña. Si la has olvidado, entonces tienes que hacer olvidó la contraseña",
                  style: secondarytextStyle()),
              15.height,
              TextFormField(
                style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(
                      color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
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
                    return 'La contraseña es requerida';
                  }
                  return null;
                },
              ),
              15.height,
              TextFormField(
                style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
                  labelText: 'Confirmar contraseña',
                  labelStyle: TextStyle(
                      color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
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
                    return 'La confirmación de contraseña es requerida';
                  }
                  return null;
                },
              ),
              14.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: Checkbox(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                  ),
                  Text(
                    'Recordarme',
                    style: TextStyle(
                        color: appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
