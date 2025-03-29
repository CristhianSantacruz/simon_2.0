import '../utils/constant.dart';
import '../utils/images.dart';

class GenNotificationResponse {
  List<GenNotificationModel>? gennotificationList;

  GenNotificationResponse({this.gennotificationList});
}

class GenNotificationModel {
  final String authorImage;
  final String authorName;
  final String notificationText;
  final String date;
  final String time;
  //final String contentImage;

  GenNotificationModel({
    required this.authorImage,
    required this.authorName,
    required this.notificationText,
    required this.date,
    required this.time,
    //required this.contentImage,
  });
}

List<GenNotificationModel> getGenNotificationModelList() {
  List<GenNotificationModel> gennotificationList = [];
  gennotificationList.add(GenNotificationModel(
    authorImage: AuthorImage.authEliza,
    authorName: AuthorName.authElina,
    notificationText: ' Tu iimpugnación ha sido recibida por el juez!',
    date: 'Hace 3 días',
    time: '07:24 PM',
    //contentImage: ArticleImage.authElina,
  ));
  gennotificationList.add(
    GenNotificationModel(
      authorImage: AuthorImage.authEliza,
      authorName: AuthorName.authChris,
      notificationText: ' Impugnación rechazada',
      date: 'Hace 3 días',
      time: '01:00 PM',
      //contentImage: ArticleImage.authEliza,
    ),
  );
  return gennotificationList;
}
