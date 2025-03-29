class PaymentHistoryModel {
  final String imageAsset;
  final String title;
  final String authorImage;
  final String authorName;
  final String category;
  final String articleContent;
  final String time;

  PaymentHistoryModel({
    required this.imageAsset,
    required this.title,
    required this.authorImage,
    required this.authorName,
    required this.category,
    required this.articleContent,
    required this.time,
  });
}

List<PaymentHistoryModel> getPaymentHistoryModelList() {
  List<PaymentHistoryModel> paymentHistoryList = [];
  paymentHistoryList.add(PaymentHistoryModel(
    imageAsset: 'assets/images/payment1.png',
    title: 'Pago recibido',
    authorImage: 'assets/images/author1.png',
    authorName: 'Banco ABC',
    category: 'Pago',
    articleContent: 'Detalles del pago recibido el 15 de noviembre.',
    time: 'Hace 3 días',
  ));
  paymentHistoryList.add(PaymentHistoryModel(
    imageAsset: 'assets/images/payment2.png',
    title: 'Pago enviado',
    authorImage: 'assets/images/author2.png',
    authorName: 'Tienda XYZ',
    category: 'Pago',
    articleContent: 'Transferencia realizada el 12 de noviembre.',
    time: 'Hace 6 días',
  ));
  return paymentHistoryList;
}

