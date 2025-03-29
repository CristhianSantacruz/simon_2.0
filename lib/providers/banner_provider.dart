
import 'package:flutter/material.dart';
import 'package:simon_final/models/banner_model.dart';
import 'package:simon_final/services/banner_services.dart';

class BannerProvider extends ChangeNotifier{
  List<BannerModel> _banners = [];
  final BannerServices _bookService = BannerServices();
  List<BannerModel> get banners => _banners;

  void fetchBanners() async  {
    _banners =  await _bookService.getBanners();
    notifyListeners();
  }

}