
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:simon_final/models/user_model.dart';
import 'package:simon_final/providers/comments_bydocument_provider.dart';
import 'package:simon_final/providers/page_controller_provider.dart';
import 'package:simon_final/providers/switch_provider.dart';
import 'package:simon_final/screens/auth/new_sign_in.dart';
import 'package:simon_final/screens/directions/add_direction_screen.dart';
import 'package:simon_final/screens/directions/directions_screen.dart';
import 'package:simon_final/screens/documents_user/view_docs/docs_vehicle_Associated_screen.dart';
import 'package:simon_final/screens/documents_user/view_docs/view_vehicle_document.dart';
import 'package:simon_final/screens/profiles/registered_profiles.dart';
import 'package:simon_final/screens_export.dart';
import 'firebase_and_notifications.dart'; // Importamos el archivo de configuración

AppStore appStore = AppStore();

void main() async {
  //debugRepaintRainbowEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();

    // Inicializa Firebase y las notificaciones
  await FirebaseAndNotifications.initialize();

  await SharedPreferences.getInstance();

 // debugDefaultTargetPlatformOverride = TargetPlatform.android;
 
  runApp(
    MultiProvider(
      providers: [
        Provider<AppStore>(create: (_) => AppStore()),
        ChangeNotifierProvider<BannerProvider>(create: (_) => BannerProvider()),
        ChangeNotifierProvider<DocumentUserProvider>(create: (_) => DocumentUserProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DocumentsGenerateProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => DocumentCommentProvider()),
        ChangeNotifierProvider(create: (_) => PageControllerProvider(),),
        ChangeNotifierProvider(create: (_) => SwitchProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.transparent,
      statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark,
    ));
    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const <Locale>[Locale('es', 'ES')],	
        title: 'Simón',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const SplashScreen(),
        routes: {
          Routes.singIn: (context) => const SignInScreen(),
          Routes.singUp: (context) => const  NewRegisterScreen(),
          Routes.forgetPassword: (context) => const ForgotPasswordScreen(),
          Routes.splash: (context) => const SplashScreen(),
          Routes.walkthrough: (context) => const WalkthroughScreen(),
          Routes.docsAcountAssociated : (context) => const DocsAccountAssociatedScreen(),
          Routes.docsVehiculo : (context) => const DocsVehicleAssociatedScreen(),
          Routes.createVehicle: (context) => const RegisterCarUser(),
          Routes.templates : (context) => const TemplatesScreen(),
          Routes.dashboard : (context) => const DashboardScreen(initialIndex: 0),
          Routes.showfines : (context) => const ShowMultasScreen(),
          Routes.docunmentGenerated : (context) => const DocsDocumentsGeneratedScreen(),
          Routes.notifications : (context) => const NotificationScreen(),
          Routes.viewVehicleDocument : (context) => const ViewVehicleDocument(),
          Routes.addAddress : (context) => const AddDirectionScreen(),
          Routes.directions : (context) => const DirectionsUser(),
          Routes.registerCar : (context) => const RegisterCarUser(),
          Routes.impugnaMultas : (context) => const TemplatesScreen(),
          Routes.adminProfiles : (context) => const MyProfiles(),
          Routes.newSignIn : (context) => const NewSignIn(),
        },
      ),
    );
  }
}
