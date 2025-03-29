import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/user_model_register.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/register_service.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/messages_toast.dart';

class ChangePasswordScreen extends StatefulWidget {
  final UserModelRegiser userModelRegiser;
  const ChangePasswordScreen({super.key, required this.userModelRegiser});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final userServices = RegisterService();
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
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void updateDataUserPrincipal(UserModelRegiser userRegister, int userId,String newPassword) {
    userServices.updateUser(userRegister, userId,password: newPassword).then((value) {
      MessagesToast.showMessageSuccess("Se ha cambiado la contraseña");
      Navigator.pop(context);
      Navigator.pop(  context);
    }).catchError((error) {
      MessagesToast.showMessageError("Error al cambiar la contraseña");
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
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
          title: Text('Cambiar Contraseña',
              style: primarytextStyle(
                  color: appStore.isDarkMode ? Colors.white : Colors.black)),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios))),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: newPasswordController,
              obscureText: viewPassword,
              onChanged: checkPassword,
              style: TextStyle(
                  color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
              decoration: InputDecoration(
                fillColor:
                    appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
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
                hintStyle: TextStyle(
                    color:
                        appStore.isDarkMode ? scaffoldLightColor : resendColor),
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
                if (password != confirmPasswordController.text) {
                  return 'Las contraseñas no coinciden';
                }
        
                return null; // Si pasa todas las validaciones
              },
            ),
            20.height,
            TextFormField(
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Confirmar contraseña es requerida';
                }
                if(value != newPasswordController.text){
                  return 'Las contraseñas no coinciden';
                }
                return null;
        
              },
              controller: confirmPasswordController,
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
            ),
            20.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildValidationRow(
                    "Debe contener al menos una letra mayúscula", hasUppercase),
                buildValidationRow("Debe tener al menos 8 caracteres",
                    newPasswordController.text.length >= 8),
                buildValidationRow("Debe incluir al menos un número", hasNumber),
              ],
            ),
            30.height,
            AppButton(
              width: double.infinity,
              elevation: 2,
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  updateDataUserPrincipal(widget.userModelRegiser, userProvider.user.id,newPasswordController.text);
                }
              },
              color: simon_finalPrimaryColor,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
              child: Text("Cambiar Contraseña",
                  style: primarytextStyle(size: 14, weight: FontWeight.w500,color: Colors.white)),
            )
        
          ],
        ).paddingAll(16),
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
