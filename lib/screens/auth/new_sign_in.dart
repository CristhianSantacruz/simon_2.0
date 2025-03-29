
import 'package:simon_final/components/simon/pop_up_widget.dart';
import 'package:simon_final/components/simon/text_form_register.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/pop_up_model.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/login_register_services.dart';
import 'package:simon_final/services/pop_up_service.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/images.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class NewSignIn extends StatefulWidget {
  const NewSignIn({super.key});

  @override
  State<NewSignIn> createState() => _NewSignInState();
}

class _NewSignInState extends State<NewSignIn> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Size mediaSize;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mediaSize = MediaQuery.of(context).size; // Se accede aquí sin problemas
  }

  final _loginService = LoginService();

  bool _obscureText = true;

Future<void> login(
    String email, String password, UserProvider userProvider) async {
  debugPrint("Datos del Login: $email $password");
  final response = await _loginService.login(email, password, userProvider);

  if (response['success'] == true) {
    MessagesToast.showMessageSuccess("Inicio de Sesion Exitoso");

    // Obtener datos del pop-up antes de navegar
    final popupResponse = await PopUpService().getPopUpRandom();

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        Routes.dashboard,
        arguments: popupResponse, // Pasamos el pop-up como argumento
      );
    }
  } else {
    MessagesToast.showMessageError(response['error']);
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: simon_finalPrimaryColor,
      body: Stack(children: [
        Positioned(top: 80, child: _buildTop()),
        Positioned(bottom: 0, child: _buildBottom()),
      ]),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.white, // Color deseado
              BlendMode.srcATop, // Modo de mezcla para aplicar el color
            ),
            child: Image.asset(
              legal_2_png,

              fit: BoxFit.contain, // Mejor ajuste para logos
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        )),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          5.height,
          Text(
            "Bienvenido ",
            style: primarytextStyle(
                color: appStore.isDarkMode ? Colors.white : Colors.black,
                size: 30),
          ),
          _buildGreyText("Por favor inicia sesión con tu información"),
          const SizedBox(height: 30),
          _buildInputFieldEmail(emailController),
          const SizedBox(height: 20),
          TextFormField(
            controller: passwordController,
            style: TextStyle(
                color: appStore.isDarkMode ? Colors.white : Colors.black),
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.lock,
                color: simon_finalPrimaryColor,
              ),
              filled: true,
              fillColor:
                  appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
              labelText: 'Contraseña',
              labelStyle: TextStyle(
                  color: appStore.isDarkMode
                      ? scaffoldLightColor
                      : scaffoldDarkColor),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility),
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
              await login(emailController.text, value, userProvider);
            },
          ),
          const SizedBox(height: 20),
          _buildRememberForgot(),
          const SizedBox(height: 5),
          _buildLoginButton(),
          const SizedBox(height: 20),
          30.height,
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Aún no tienes cuenta? ',
                  style: TextStyle(
                      color: appStore.isDarkMode
                          ? scaffoldLightColor
                          : Colors.black,
                      fontSize: 13),
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
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: resendColor),
    );
  }

  Widget _buildInputFieldEmail(TextEditingController controller,
      {isPassword = false}) {
    return TextFormFieldRegister(
        label: "Correo Electronico",
        icon: const Icon(
          Icons.email,
          color: simon_finalPrimaryColor,
        ),
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return 'El correo es requerido';
          } else if (!emailValidate.hasMatch(value)) {
            return 'Por favor ingrese un Email valido';
          }
          return null;
        });
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
            onPressed: () {
              _launchURL("https://simon_final.devnarviz.com/password/reset");
            },
            child: _buildGreyText("¿Olvidastes tu contraseña?"))
      ],
    );
  }

  Widget _buildLoginButton() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          login(emailController.text, passwordController.text, userProvider);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: simon_finalPrimaryColor,
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: simon_finalPrimaryColor,
        minimumSize: const Size.fromHeight(60),
      ),
      child: Text(
        "Iniciar Sesión",
        style: primarytextStyle(color: Colors.white, size: 18),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'No se pudo abrir $url';
    }
  }
}
