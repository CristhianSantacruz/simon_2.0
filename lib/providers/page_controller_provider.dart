import 'package:simon_final/screens_export.dart';

class PageControllerProvider with ChangeNotifier {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _totalPages = 0;

  PageController get pageController => _pageController;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  void setTotalPages(int totalPages) {
    _totalPages = totalPages;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < _totalPages - 1) {
      _currentPage++;
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // Función para ir a la página anterior
  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      _pageController.animateToPage(
        page,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void reset() {
    _currentPage = 0;
    _totalPages = 0;
   // _pageController.jumpToPage(0);
    notifyListeners();
  }

  bool isLastPage() {
    return _currentPage == _totalPages - 1;
  }
}
