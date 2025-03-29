import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:simon_final/components/faq_component.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/models/faq_question_model.dart';
import 'package:simon_final/services/faq_question_services.dart';
import 'package:simon_final/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/text_styles.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> with SingleTickerProviderStateMixin {
  TabController? _tabController;
    List<Category> categories = [];
  List<FaQuestionModel> allFaqs = [];
  List<FaQuestionModel> filteredFaqs = [];
  int selectedCategoryId = 0; // ID de la categoría seleccionada

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFaqData();

  }

  Future<void> _fetchFaqData() async {
    try {
      List<FaQuestionModel> faqs = await FaqQuestionServices().getFaqQuestions();

      // Obtener categorías únicas de las preguntas
      Set<int> categoryIds = faqs.map((faq) => faq.categoryId).toSet();
      List<Category> fetchedCategories = categoryIds.map((id) {
        return faqs.firstWhere((faq) => faq.categoryId == id).category;
      }).toList();

      setState(() {
        allFaqs = faqs;
        categories = fetchedCategories;
        if (categories.isNotEmpty) {
          selectedCategoryId = categories.first.id; // Seleccionar la primera categoría por defecto
          _filterFaqsByCategory();
        }
      });
    } catch (e) {
      print("Error al obtener las preguntas frecuentes: $e");
    }
  }

   void _filterFaqsByCategory() {
    setState(() {
      filteredFaqs = allFaqs.where((faq) => faq.categoryId == selectedCategoryId).toList();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_ios, color: appStore.isDarkMode ? Colors.white : Colors.black)),
          surfaceTintColor: appStore.isDarkMode ? scaffoldDarkColor : context.scaffoldBackgroundColor,
          iconTheme: IconThemeData(color: appStore.isDarkMode ? Colors.white : Colors.black),
          centerTitle: true,
          title: Text('Centro de ayuda', style: primarytextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black,)),
          backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : context.scaffoldBackgroundColor,
          bottom: TabBar(
            controller: _tabController,
            labelColor: appStore.isDarkMode ? scaffoldLightColor : simon_finalPrimaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'FAQ'),
              Tab(text: 'Contáctanos'),
            ],
          ),
        ),
        body: TabBarView(controller: _tabController, children: [
     Column(
              children: [
                // Categorías en botones
                Align(
                  alignment: Alignment.topLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 22),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(DEFAULT_RADIUS)
                              ),
                              backgroundColor: selectedCategoryId == category.id
                                  ? simon_finalPrimaryColor
                                  : Colors.grey[300],
                              foregroundColor: selectedCategoryId == category.id
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                selectedCategoryId = category.id;
                                _filterFaqsByCategory();
                              });
                            },
                            child: Text(category.category),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Preguntas frecuentes filtradas
                Expanded(
                  child: filteredFaqs.isEmpty
                      ? const Center(child: LoaderAppIcon())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: filteredFaqs.length,
                          itemBuilder: (context, index) {
                            FaQuestionModel faq = filteredFaqs[index];

                            return FaqTileWidget(title: faq.question, childrenText: faq.answer);
                          },
                        ),
                ),
              ],
            ),
          Column(children: contactUsWidgets),
        ]),
      );
    });
  }
}
