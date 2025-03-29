import 'package:simon_final/models/notification_model.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/notifications_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/components/gen_notification_component.dart';
import 'package:simon_final/components/text_styles.dart';

import '../../main.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  //List<NotificationModel> notificationsServices = [];

  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    final userId = context.read<UserProvider>().user.id;
    _tabController = TabController(length: 2, vsync: this);
    _notificationsFuture = NotificationsServices().notificationsByUser();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }


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
          title: Text('Ultimas Notificaciones',
              style: primarytextStyle(
                  color: appStore.isDarkMode ? Colors.white : Colors.black)),
        ),
        body: FutureBuilder<List<NotificationModel>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Muestra un indicador de carga mientras se esperan las notificaciones
              return Center(child:const LinearProgressIndicator(color: simon_finalPrimaryColor,).paddingSymmetric(horizontal: 8));
            } else if (snapshot.hasError) {
              // Muestra un mensaje de error si la carga falla
              return Center(child: Text('${snapshot.error.toString().split(":").last}',style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Muestra un mensaje si no hay notificaciones
              return const Center(child: Text("No hay notificaciones disponibles."));
            } else {
              // Muestra la lista de notificaciones
              List<NotificationModel> notifications = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: GenNotificationComponent(
                              genNotificationData: notifications[index],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );
    });
  }
}
