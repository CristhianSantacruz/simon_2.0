import 'package:simon_final/components/simon/container_message_loading.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/user_model_register.dart';
import 'package:simon_final/providers/switch_provider.dart';
import 'package:simon_final/screens/auth/register_page/first_page.dart';
import 'package:simon_final/screens/auth/register_page/legends_alert_perfil_register.dart';
import 'package:simon_final/screens/auth/register_page/legends_document_message.dart';
import 'package:simon_final/screens/auth/register_page/second_page.dart';
import 'package:simon_final/screens/auth/register_page/third_page.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/login_register_services.dart';
import 'package:simon_final/services/profiles_services.dart';
import 'package:simon_final/services/register_service.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:intl/intl.dart';
import '../../../models/profile_model_register.dart';

class NewRegisterScreen extends StatefulWidget {
  final bool? isCreateProfile;
  const NewRegisterScreen({super.key, this.isCreateProfile = false});

  @override
  State<NewRegisterScreen> createState() => _NewRegisterScreenState();
}

class _NewRegisterScreenState extends State<NewRegisterScreen> {
  late List<Widget> pages;
  int currentIndex = 0;
  late PageController _pageController;
  final _registerService = RegisterService();
  final _loginService = LoginService();
  final _profileServices = ProfilesServices();


  bool _isLoading = false;

  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    pages = [
      const LegendsDocumentMessage(),
      FirstPage(
          isCreateProfile:
              widget.isCreateProfile), // Puedes pasar otros valores también
      SecondPage(
        isCreateProfile: widget.isCreateProfile,
      ),
      ThirdPage(
        isCreateProfile: widget.isCreateProfile,
      ),
      if(widget.isCreateProfile  == true) const LegendsAlertPerfilRegister(
        
         
        ),
      // Puedes añadir otras páginas si es necesario
    ];

    FirstPage.userNameController.clear();
    FirstPage.lastNameController.clear();
    FirstPage.birthdayController.clear();
    FirstPage.maritalStatusController.clear();

    SecondPage.professionController.clear();
    SecondPage.maritalStatusController.clear();
    SecondPage.phoneController.clear();
    SecondPage.identificationTypeController.clear();
    SecondPage.identificationController.clear();
    SecondPage.nombramientoController.clear();

    // tercera solo para la matricula

    ThirdPage.emailController.clear();
    ThirdPage.confirmEmailController.clear();
    ThirdPage.passwordController.clear();
    ThirdPage.confirmPasswordController.clear();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  Future<void> register(
      UserModelRegiser userRegister, UserProvider userProvider) async {
    setState(() {
      _isLoading = true;
    });

    final response = await _registerService.register(userRegister);
    if (response['success'] == true) {
      // Registro exitoso
      // Mostrar CircularProgressIndicator
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(const Duration(seconds: 1), () {});

      // Iniciar sesión automáticamente
      await login(userRegister.email, userRegister.password!, userProvider);
    } else {
      setState(() {
        currentIndex = 0;
        _isLoading = false;
      });
      MessagesToast.showMessageError("${response['error']}");
    }
  }

  Future<void> registerProfile(ProfileModelRegister profileRegister) async {
    try {
      await _profileServices.createProfile(profileRegister);
      MessagesToast.showMessageSuccess("Perfil creado");
      Navigator.pop(context, true);
    } catch (e) {
      MessagesToast.showMessageError("Error al crear el perfil");
    }
  }

  Future<void> login(
      String email, String password, UserProvider userProvider) async {
    final response = await _loginService.login(email, password, userProvider);
    if (response['success'] == true) {
      toast("Bienvenido a tu asistente virtual",
          textColor: Colors.white,
          bgColor: simon_finalPrimaryColor,
          gravity: ToastGravity.TOP);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const DashboardScreen(initialIndex: 0)));
    } else {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          dismissDirection: DismissDirection.up,
          behavior: SnackBarBehavior.floating,
          content: Text('${response['error']}'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextPage() {
    if (currentIndex == 1 && !FirstPage.formKey.currentState!.validate()) {
      return;
    }
    if (currentIndex == 2 && !SecondPage.formKey.currentState!.validate()) {
      return;
    }
    if (currentIndex == 3 && !ThirdPage.formKey.currentState!.validate()) {
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void finalRegister() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logout();
    if (ThirdPage.formKey.currentState!.validate()) {
      DateTime birthDate =
          DateFormat('yyyy-MM-dd').parse(FirstPage.birthdayController.text);
      UserModelRegiser userModelRegiser = UserModelRegiser(
          name: FirstPage.userNameController.text,
          lastName: FirstPage.lastNameController.text,
          typeIdentification: SecondPage.identificationTypeController.text,
          password: ThirdPage.passwordController.text,
          maritalStatus: FirstPage.maritalStatusController.text,
          identification: SecondPage.identificationController.text,
          profession_id: SecondPage.professionController.text.toInt(),
          email: ThirdPage.emailController.text,
          phone: SecondPage.phoneController.text,
          sexo: FirstPage.genderController.text,
          nombramiento: SecondPage.nombramientoController.text,
          birthDate: birthDate);
      debugPrint("Datos: ${userModelRegiser.toJson()}");
      await register(userModelRegiser, userProvider);
    }
  }

  void finalRegisterProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final switchProvider = Provider.of<SwitchProvider>(context, listen: false);
  
      DateTime birthDate =DateFormat('yyyy-MM-dd').parse(FirstPage.birthdayController.text);
      ProfileModelRegister profileModelRegiser = ProfileModelRegister(
          name: FirstPage.userNameController.text,
          lastName: FirstPage.lastNameController.text,
          typeIdentification: SecondPage.identificationTypeController.text,
          maritalStatus: FirstPage.maritalStatusController.text,
          identification: SecondPage.identificationController.text,
          email: ThirdPage.emailController.text,
          phone: SecondPage.phoneController.text,
          nombramiento: SecondPage.nombramientoController.text,
          birthDate: birthDate,
          sexo: FirstPage.genderController.text,
          professionId: SecondPage.professionController.text.toInt(),
          userId: userProvider.user.id);
      
      debugPrint("Datos del perfil: ${profileModelRegiser.toJson()}");
      await registerProfile(profileModelRegiser).then((_){
        switchProvider.resetSwitch();
      });
    
  }

  @override
  Widget build(BuildContext context) {
    bool isPerfilAuthorized = context.watch<SwitchProvider>().isSwitchedOn;
    return Scaffold(
      body: _isLoading
          ? ContainerMessageLoading(
              textTitle: "Estamos prepando todo para ti",
              textSubtitle: FirstPage.userNameController.text)
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, top: 40, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          backgroundColor: simonGris,
                          color: simon_finalPrimaryColor,
                          value: (currentIndex + 1) / pages.length,
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 20,
                        ),
                      ),
                      const SizedBox(
                          width: 10), // Espaciado entre la barra y el texto
                      Text(
                        '${currentIndex + 1}/${pages.length}', // Muestra el índice actual sobre el total
                        style: TextStyle(
                          color: appStore.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 2, 15, 15),
                    child: PageView(
                      physics:
                          const NeverScrollableScrollPhysics(), //! No deberia ser scrollable
                      controller: _pageController,
                      children: pages,
                      onPageChanged: (i) {
                        setState(() {
                          currentIndex = i;
                        });
                      },
                      padEnds: true,
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  currentIndex == 0
                      ? AppButton(
                          elevation: 0,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          color: appStore.isDarkMode
                              ? const Color(0xFF1F222A)
                              : skipbutton,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Text('Regresar',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : simon_finalPrimaryColor)),
                        ).expand()
                      : AppButton(
                          elevation: 0,
                          onTap: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          color: appStore.isDarkMode
                              ? const Color(0xFF1F222A)
                              : skipbutton,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Text('Anterior',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: appStore.isDarkMode
                                      ? Colors.white
                                      : simon_finalPrimaryColor)),
                        ).expand(),
                  16.width,
                  currentIndex != pages.length -1
                      ? AppButton(
                          elevation: 2,
                          onTap: _nextPage,
                          color: simon_finalPrimaryColor,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Text( currentIndex == 0 ? 'Aceptar' : 'Siguiente',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                        ).expand()
                      :   AppButton(
                          elevation: 2,
                          onTap: () {
                            if (widget.isCreateProfile == true) {
                                 if(isPerfilAuthorized){
                                  finalRegisterProfile();
                                } else {
                                  MessagesToast.showMessageError("Debes aceptar que la persona autoriza el uso de sus datos personales.");
                                } 
                               debugPrint("Valor del switch: ${isPerfilAuthorized}");
                            } else {
                              finalRegister();
                            }
                          },
                          color: simon_finalPrimaryColor,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                              widget.isCreateProfile == true
                                  ? 'Crear Perfil'
                                  : 'Registrarse',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                        ).expand() 
                ],
              ).paddingAll(16)),
    );
  }
}
