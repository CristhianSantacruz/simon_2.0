import 'dart:async';
import 'package:simon_final/screens_export.dart';
import '../main.dart';
import '../utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _dataPreferencesUserExists = false;
  @override
  void initState() {
    super.initState();
    checkFirstSeenAndRedirect();
  }

   Future<void> checkFirstSeen() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser(); // Carga los datos del usuario
    await userProvider.loadUserPrincipalData(); // Carga los datos del usuario principal

    if (userProvider.user.id != 0 && userProvider.user.id != -1) {
      setState(() {
        _dataPreferencesUserExists = true;
      });
    }
  }

  Future<void> checkFirstSeenAndRedirect() async {
    // Primero, verifica si el usuario ya existe usando el Provider
    await checkFirstSeen();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = prefs.getBool('seen') ?? false;

    // Decide a qué pantalla redirigir
    String routeName;
    if (_dataPreferencesUserExists) {
      routeName = Routes.dashboard;
    } else {
      await prefs.setBool('seen', true);
      routeName = Routes.walkthrough;
    }

    // Usa un Timer para redirigir después de 4 segundos
    Timer(
      Duration(seconds: 4),
      () => Navigator.pushReplacementNamed(context, routeName),
    );
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          appStore.isDarkMode ? scaffoldDarkColor : Colors.transparent,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    ));
    return Observer(builder: (context) {
      return Scaffold(
        backgroundColor: simon_finalPrimaryColor,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Image.asset('assets/Logo Simon_1.gif',
                      width: 200, fit: BoxFit.cover)),
            ],
          ),
        ),
      );
    });
  }
}
