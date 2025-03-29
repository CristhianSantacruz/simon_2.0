import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAndNotifications {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Inicializa Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Solicitar permisos para notificaciones en iOS
    await _requestNotificationPermissions();

    // Inicializa las notificaciones locales
    await _initializeLocalNotifications();

    // Obtén el token del dispositivo
    await _getDeviceToken();

    // Configura los listeners de las notificaciones
    _setupNotificationListeners();

    // Inicializar Firebase Analytics
    await _initializeAnalytics();
  }

  // Inicializa Firebase Analytics con el userId almacenado
  static Future<void> _initializeAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      await analytics
          .setUserId(); // Establece el ID de usuario en Firebase Analytics
      print('Firebase Analytics inicializado con User ID: $userId');
    } else {
      print('No se encontró un User ID guardado');
    }
  }

  // Método para solicitar permisos en iOS
  static Future<void> _requestNotificationPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso concedido para recibir notificaciones');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Permiso provisional concedido');
    } else {
      print('Permiso denegado para recibir notificaciones');
    }
  }

  // Método para inicializar las notificaciones locales
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Método para obtener el token del dispositivo
  static Future<void> _getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        print('Token del dispositivo: $token');
      } else {
        print('No se pudo obtener el token');
      }
    } catch (e) {
      print('Error al obtener el token: $e');
    }
  }

  static Future<String> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        print('Token del dispositivo: $token');
        return token;
      } else {
        throw Exception('No se pudo obtener el token');
      }
    } catch (e) {
      throw Exception('No se pudo obtener el token');
    }
  }

  // Método para configurar los listeners de las notificaciones
  static void _setupNotificationListeners() {
    // Notificaciones cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(
          'Notificación recibida mientras la app está en primer plano: ${message.notification?.title}');
      await _showLocalNotification(message);
    });

    // Notificaciones cuando la app está en segundo plano o cerrada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta: ${message.notification?.title}');
      // Puedes agregar lógica para abrir una pantalla específica cuando el usuario hace clic en la notificación
    });

    // Notificaciones cuando la app está completamente cerrada
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Manejo de mensajes en segundo plano
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.notification?.title}");
    // Aquí puedes agregar la lógica para manejar la notificación en segundo plano
  }

  // Método para mostrar una notificación local
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(0, message.notification?.title,
        message.notification?.body, notificationDetails);
  }

  static Future<void> showManualNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id', // Debe coincidir con el canal que usas
      'channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // ID de la notificación (puedes cambiarlo para que no se sobreescriban)
      title, // Título personalizado
      body, // Cuerpo del mensaje personalizado
      notificationDetails,
    );
  }

  // Método de acción al seleccionar la notificación
  static Future<void> _onSelectNotification(String? payload) async {
    print("Notificación seleccionada con payload: $payload");
    // Agregar la lógica para abrir la pantalla correspondiente al seleccionar la notificación
  }
}
