import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/screens/auth/new_sign_in.dart';
import 'package:simon_final/screens/dashboard/dashboard.dart';
import 'package:simon_final/utils/app_routes.dart';
import 'package:simon_final/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/screens/auth/sign_in.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../main.dart';
import '../models/walkthrough_model.dart';
import '../utils/colors.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  bool _dataPreferencesUserExists = false;


  @override 
  void initState(){
    super.initState();
  
    checkFirstSeen();
    
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




  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: appStore.isDarkMode ? const Color(0xFF181A20) : Colors.transparent,
      statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark,
    ));
    int totalPageCount = 2;
    return Observer(builder: (context) {
      return Scaffold(
        backgroundColor: appStore.isDarkMode ? const Color(0xFF181A20) : Colors.white,
        body: Stack(
          children: [
            PageView.builder(
                controller: _pageController,
                itemCount: walkthroughList.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  WalkModel data = walkthroughList[i];

                  return Observer(builder: (context) {
                    return buildPage(
                      data.imagePath,
                      data.title,
                      data.subtitle,
                    );
                  });
                }),
            buildDotIndicator(),
          ],
        ),
        bottomNavigationBar: Observer(
          builder: (_) => _currentIndex == totalPageCount
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AppButton(
                    elevation: 2,
                    onTap: () {
                      if(_dataPreferencesUserExists==false){
                         const NewSignIn().launch(context);
                      }else {
                         const DashboardScreen(initialIndex: 0).launch(context);
                      }
                    },
                    color: simon_finalPrimaryColor,
                    shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
                    child: const Text('Comencemos',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButton(
                      elevation: 2,
                      onTap: () {
                         if(_dataPreferencesUserExists==false){
                           Navigator.pushNamedAndRemoveUntil(context, Routes.newSignIn,(Route<dynamic> route) => false);
                         } else {
                           const DashboardScreen(initialIndex: 0,).launch(context);
                           Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard,(Route<dynamic> route) => false);
                        }
                      },
                      color: appStore.isDarkMode ? const Color(0xFF1F222A) : skipbutton,
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Text('Saltar',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: appStore.isDarkMode ? Colors.white : simon_finalPrimaryColor)),
                    ).expand(),
                    16.width,
                    AppButton(
                      elevation: 2,
                      onTap: () {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      color: simon_finalPrimaryColor,
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: const Text('Siguiente',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                    ).expand(),
                  ],
                ).paddingAll(16),
        ),
      );
    });
  }


Positioned buildDotIndicator() {
  return Positioned(
    bottom: 20,
    left: 20,
    right: 20,
    child: Center(
      child: SmoothPageIndicator(
        controller: _pageController,  // PageController para gestionar el indicador
        count: walkthroughList.length,  // Número total de páginas
        effect: const ExpandingDotsEffect(
          activeDotColor: simon_finalPrimaryColor,
          dotColor: Color(0xFF35383E),
          dotHeight: 8,
          dotWidth: 12,
          expansionFactor: 3, // Controla cuánto se expande el punto activo
          spacing:10,
        ),
      ),
    ),
  );
}


  Widget buildPage(String Function() imagePath, String title, String subtitle) {
  return Stack(
    children: [
      /// Imagen de fondo que cubre toda la pantalla
      Positioned.fill(
        child: Image.asset(
          imagePath(), 
          fit: BoxFit.cover, // Cubre toda la pantalla
        ),
      ),

      /// Degradado en la parte inferior
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent, // Transparente en la parte superior
                Colors.white.withOpacity(0.8), // Degradado blanco intermedio
                Colors.white, // Totalmente blanco en la parte inferior
              ],
              stops: [0.5, 0.75, 1], // Controla el efecto del degradado
            ),
          ),
        ),
      ),

      /// Contenido del texto centrado
      Positioned(
        bottom: 100, // Ajusta según sea necesario
        left: 16,
        right: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}