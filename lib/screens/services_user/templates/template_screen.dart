// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/models/template_model.dart';
import 'package:simon_final/screens/services_user/templates/template_details.dart';
import 'package:simon_final/services/template_services.dart';
import 'package:simon_final/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/text_styles.dart';
import '../../../../main.dart';
import '../../../../utils/colors.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _ImpugnaMultasScreenState();
}

class _ImpugnaMultasScreenState extends State<TemplatesScreen> {
  final TemplateServices _templateServices = TemplateServices();
  List<TemplateModel> templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    try {
      List<TemplateModel> fetchedTemplates =
          await _templateServices.getTemplates();
      setState(() {
        templates = fetchedTemplates;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error al cargar las plantillas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new,
                    color: appStore.isDarkMode ? Colors.white : Colors.black)),
            centerTitle: true,
            surfaceTintColor: appStore.isDarkMode
                ? scaffoldDarkColor
                : context.scaffoldBackgroundColor,
            iconTheme: IconThemeData(
                color: appStore.isDarkMode ? Colors.white : Colors.black),
            title: Text(
              "Selecciona tu Documento",
              style: primarytextStyle(
                color: appStore.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            backgroundColor: appStore.isDarkMode
                ? scaffoldDarkColor
                : context.scaffoldBackgroundColor,
          ),
          body: _isLoading
              ? const Center(child: LoaderAppIcon())
              : TemplateFragment(templates: templates),
        );
      },
    );
  }
}

class TemplateFragment extends StatelessWidget {
  const TemplateFragment({
    super.key,
    required this.templates,
  });

  final List<TemplateModel> templates;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return _TemplateContainer(template: template);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateContainer extends StatefulWidget {
  const _TemplateContainer({
    required this.template,
  });

  final TemplateModel template;

  @override
  State<_TemplateContainer> createState() => _TemplateContainerState();
}

class _TemplateContainerState extends State<_TemplateContainer> {
  late int numberOfSections;
  late int numberOfFiles;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    numberOfSections = widget.template.templateSections.length;
    numberOfFiles = widget.template.templateSections
        .where((section) =>
            section.templateFields.any((field) => field.fieldType == "file"))
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
        border: Border.all(
          color: simon_finalPrimaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y precio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.template.name,
                style: primarytextStyle(
                    color:
                        appStore.isDarkMode ? scaffoldLightColor : Colors.black,
                    size: 16),
              ),
              Text(
                "\$${widget.template.totalPrice.toStringAsFixed(2)}", // Muestra el precio con 2 decimales
                style: primarytextStyle(
                  color:
                      appStore.isDarkMode ? scaffoldLightColor : Colors.black,
                  size: 16,
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Espacio entre título y descripción
          // Descripción debajo del título
          Text(
            "${widget.template.description}",
            style: primarytextStyle(
                color: appStore.isDarkMode ? scaffoldLightColor : Colors.grey,
                size: 11),
          ),
          const SizedBox(
              height: 12), // Espacio entre descripción y siguiente fila
          // Fila interactiva para navegar
          GestureDetector(
            onTap: () {
              // Navegar al detalle del documento cuando se toca el área
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TemplateDetailPage(
                    templateId: widget.template.id,
                    nameTemplate: widget.template.name,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: simon_finalPrimaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Color de la sombra
                    blurRadius: 10, // Cuánto se difumina la sombra
                    offset: const Offset(
                        0, 5), // Desplazamiento de la sombra (elevación)
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    // Permite que el texto se ajuste sin desbordar
                    child: Text(
                      "Empezar proceso de impugnación",
                      style: primarytextStyle(color: Colors.white, size: 15),
                      overflow: TextOverflow
                          .ellipsis, // Corta el texto si es muy largo
                      maxLines: 1, // Máximo 1 línea
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.article,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
