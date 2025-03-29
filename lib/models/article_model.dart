
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/app_routes.dart';

import '../utils/constant.dart';
import '../utils/images.dart';

class ArticleResponse {
  final String title;

  final String? listType;

  final List<ArticleModel>? articleList;

  ArticleResponse({
    this.title = '',
    this.listType,
    this.articleList,
  });
}

List<ArticleResponse> getArticleResponse() {
  List<ArticleResponse> articleList = [];
  List<ArticleModel> paymentHistoryList = [];
  articleList.add(
    ArticleResponse(
        title: 'Servicios',
        articleList: getServicesModelList(),
        listType: recent_article),
  );
  articleList.add(
    ArticleResponse(
        title: 'Documentos',
        articleList: getDocuementsModelList(),
        listType: your_article),
  );
  return articleList;
}

//Documents List
List<ArticleModel> getDocuementsModelList() {
  List<ArticleModel> articleList = [];
  //articleList.add(ArticleModel(imageAsset: ArticleImage.documentFinish,title: ArticleTitle.authDocumentAsociatedImpugnacion,routeName: Routes.docsImpugnacion));
  articleList.add(ArticleModel(
       isImagePng:  true,
      imageAsset: HomeImages.document_writer,
    title: ArticleTitle.authDocumentGenerateds,
    routeName: Routes.docunmentGenerated,
  ));
  articleList.add(ArticleModel(
      imageAsset: HomeImages.resume_cv_icon_svg,
      title: ArticleTitle.authDocumentAsociatedCuenta,
      routeName: Routes.docsAcountAssociated));

  articleList.add(ArticleModel(
       isImagePng:  true,
      imageAsset: HomeImages.car_document_icon_png,
      title: ArticleTitle.authDocumentAsociadoVehiculo,
      routeName: Routes.viewVehicleDocument));

  return articleList;
}

//Recent Articles List
List<ArticleModel> getPaymentHistoryModelList() {
  List<ArticleModel> paymentHistoryList = [];

  paymentHistoryList.add(ArticleModel(
    imageAsset: 'assets/images/payment1.png',
    title: 'Pago recibido',
  ));

  paymentHistoryList.add(ArticleModel(
    imageAsset: 'assets/images/payment2.png',
    title: 'Pago enviado',
  ));
  paymentHistoryList.add(ArticleModel(
    imageAsset: 'assets/images/payment3.png',
    title: 'Devolución de pago',
  ));

  return paymentHistoryList;
}

//Services List
List<ArticleModel> getServicesModelList() {
  List<ArticleModel> articleList = [];
  articleList.add(ArticleModel(
    imageAsset:HomeImages.create_document_icon_png,
    title: ArticleTitle.authServicesRevisaTemplate,
    routeName: Routes.templates,
    isImagePng: true
    
  ));

  articleList.add(ArticleModel(
    imageAsset: HomeImages.profile_icon_png,
    title: ArticleTitle.authServiceCrearPerfiles,
    routeName: Routes.adminProfiles,
    isImagePng: true,
    
  ));
  
  
  return articleList;
}

class ArticleModel {
  final String? imageAsset;
  final String? title;
  final String? routeName;
  final bool? isImagePng;
  ArticleModel(
      {this.imageAsset, this.title, this.routeName,this.isImagePng=false});
}
