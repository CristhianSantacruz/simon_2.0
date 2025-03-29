import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:simon_final/components/simon/alert_dialog.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/components/simon/text_form_field_simon.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/addres_model.dart';
import 'package:simon_final/models/template_model.dart';
import 'package:simon_final/models/user_document_type_model.dart';
import 'package:simon_final/providers/documents_generated_providers.dart';
import 'package:simon_final/providers/documents_user.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/providers/vehicles_user_provider.dart';
import 'package:simon_final/screens/documents_user/view_docs/new_document_detail.dart';
import 'package:simon_final/screens/services_user/templates/template_sections_details.dart';
import 'package:simon_final/screens/services_user/templates/terms_screen.dart';
import 'package:simon_final/services/address_services.dart';
import 'package:simon_final/services/template_services.dart';
import 'package:simon_final/services/user_generated_document_service.dart';
import 'package:simon_final/utils/app_routes.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:simon_final/screens/services_user/templates/payment_webview.dart';

class TemplateDetailPage extends StatefulWidget {
  final int templateId;
  final String nameTemplate;

  TemplateDetailPage({required this.nameTemplate, required this.templateId});

  @override
  State<TemplateDetailPage> createState() => _TemplateDetailPageState();
}

class _TemplateDetailPageState extends State<TemplateDetailPage> {
  final TemplateServices _templateServices = TemplateServices();
  late Future<TemplateModel> _templateFuture;
  List<GlobalKey<_TemplateDetailPageState>> sectionKeys = [];
  final UserGeneratedDocumentService _userGeneratedDocumentService =
      UserGeneratedDocumentService();

  bool _isVisible = false;
  TemplateModel? _template;
  final _addressService = AddressServices();

  //late List<AddressModel> _addresses = [];
  late AddressModel? _selectedAddress = null;
  String province = "";
  String city = "";
  bool? multaPorRadar = null;
  final GlobalKey _termsKey = GlobalKey(); // Llave para el scroll automático
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _loadAddresses(userProvider.user.id, userProvider.currentProfile);

    final DocumentUserProvider documentUserProvider =
        Provider.of<DocumentUserProvider>(context, listen: false);
    final VehicleProvider vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);

    _templateFuture = _loadTemplateById(
        widget.templateId, userProvider.user.id, userProvider.currentProfile);

    _loadData(userProvider.user.id, vehicleProvider, documentUserProvider,
        userProvider.currentProfile);

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isVisible = true;
      });
    });
    documentUserProvider.fetchDocumentsUsers(
        userProvider.user.id, userProvider.currentProfile);
  }

  void _loadData(int userId, VehicleProvider vehicleProvider,
      DocumentUserProvider documentUserProvider, int profileId) async {
    await vehicleProvider.fetchVehicles(userId, profileId);
    if (vehicleProvider.vehicleList.isEmpty) {
      _showRegistrationAlert(context);
    } else {
      _checkDocuments(documentUserProvider);
    }
  }

  void _checkDocuments(DocumentUserProvider documentUserProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<UserDocumentTypeModel> documents = documentUserProvider
          .documentsUsers
          .where((element) => element.userDocument == null)
          .toList();

      if (documents.length > 0) {
        _showUploadDocumentsUserAlert(context);
      }
    });
  }

  Future<void> _loadAddresses(int userId, int profileId) async {
    try {
      List<AddressModel> fetchedAddresses =
          await _addressService.getAddressByUser(userId, profileId);
      if (fetchedAddresses.isEmpty) {
        _showAddressDialogAlert(context);
      } else {}
      setState(() {
        _selectedAddress = fetchedAddresses.isNotEmpty
            ? fetchedAddresses
                .where(
                    (element) => element.type == TypeAdressModel.ADDRESS.name)
                .toList()[0]
            : null;
      });
      if (_selectedAddress != null) {
        await _loadStateAndCity(
            _selectedAddress!.stateId, _selectedAddress!.cityId);
      }
    } catch (e) {
      debugPrint("Error al cargar las direcciones del servicio: $e");
    }
  }

  Future<void> _loadStateAndCity(int stateId, int cityId) async {
    try {
      final states = await _addressService.getStates();
      final citys = await _addressService.getCities();
      final String state =
          states.where((element) => element.id == stateId).toList()[0].name;
      final String city =
          citys.where((element) => element.id == cityId).toList()[0].name;
      setState(() {
        this.province = state;
        this.city = city;
      });
    } catch (e) {
      debugPrint("Error al cargar los estados y ciudades del servicio: $e");
    }
  }

  @override
  void dispose() {
    TemplateSectionDetails.selectedOptions.clear();
    TemplateSectionDetails.textControllers.clear();
    // quiero ahora tambier limpiar los arhivos
    TemplateSectionDetails.selectedFiles.forEach((sectionId, files) {
      files.clear(); // Elimina todas las entradas dentro del mapa interno
    });
    TemplateSectionDetails.selectedFiles
        .clear(); // Asegura que el mapa principal también se vacíe

    super.dispose();
  }

  void _showRegistrationAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CustomAlertDialog(
          color: simon_finalPrimaryColor,
          iconData: Icons.info,
          title: "!Importante!",
          withRedirection: true,
          route: Routes.registerCar,
          textButton: "Registrar",
          content:
              "Debes registrar un vehículo para poder utilizar esta documento.",
        );
      },
    );
  }

  void _showUploadDocumentsUserAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CustomAlertDialog(
          iconData: Icons.info,
          title: "!Importante!",
          content:
              "Debes subir tus documentos de identificacion antes de generar el documento.",
          withRedirection: true,
          route: Routes.docsAcountAssociated,
        );
      },
    );
  }

  void _showAddressDialogAlert(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const CustomAlertDialog(
            title: "Importante",
            iconData: Icons.info,
            content: "Debe de registrar una direccion domiciliaria",
            withRedirection: true,
            route: Routes.directions,
          );
        });
  }

  Future<TemplateModel> _loadTemplateById(
      int templateId, int userId, int profileId) async {
    try {
      return await _templateServices.getTemplateById(
          templateId, userId, profileId);
    } catch (e) {
      debugPrint("Error al cargar la plantilla: $e");
      rethrow;
    }
  }

  void handleResponse(BuildContext context, Map<String, dynamic> response) {
    if (response['status'] == true &&
        response['data']?['payment_url'] != null) {
      String paymentUrl = response['data']['payment_url'];

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebView(url: paymentUrl),
        ),
      );
    } else {
      MessagesToast.showMessageSuccess("Documento generado correctamente");
    }
  }

  Future<Map<String, dynamic>> generateDocument(int templateId) async {
    if (!validateForm()) {
      toast(
        "Hay campos obligatorios sin completar aun.",
        gravity: ToastGravity.TOP,
        bgColor: Colors.red[400]!,
        textColor: Colors.white,
      );
      return {}; // Devuelve un mapa vacío
    }

    final userProvider = context.read<UserProvider>();

    // Mostrar el diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const LoaderAppIcon();
      },
    );

    try {
      // Llamar al servicio para generar el documento
      final response =
          await _userGeneratedDocumentService.postUserGeneratedDocuments(
        userProvider.user.id,
        userProvider.currentProfile,
        templateId,
        sendAllTemplateData(),
        getSelectedFilesBySection(),
        _selectedAddress?.id,
      );
      Navigator.of(context).pop();
      //MessagesToast.showMessageSuccess("Documento generado correctamente");
      final providerDocuments =
          Provider.of<DocumentsGenerateProvider>(context, listen: false);
      await providerDocuments.getDocumentGenerates(
          userProvider.user.id, userProvider.currentProfile);
      final lastDocument = providerDocuments.documentGenerates.last;
      debugPrint("Ultimo documento generado: ${lastDocument.toJson()}");

      handleResponse(context, response);
      return response;
    } catch (e) {
      Navigator.of(context).pop();
      debugPrint("Error al generar documento: $e");
      toast(
        "Error al generar documento: $e",
        gravity: ToastGravity.TOP,
        bgColor: Colors.red[400]!,
        textColor: Colors.white,
      );
      return {'success': false, 'error': 'Error al generar documento'};
    }
  }

  List<Map<String, dynamic>> sendAllTemplateData() {
    List<Map<String, dynamic>> fieldsData = [];

    // Iteramos por cada sección y sus datos
    TemplateSectionDetails.sections.forEach((sectionId, section) {
      // Procesar los controladores de texto para cada sección
      TemplateSectionDetails.textControllers[sectionId]
          ?.forEach((key, controller) {
        var field = section.templateFields.firstWhere(
          (field) => field.id == key,
          orElse: () => TemplateField(
            id: key,
            sectionId: sectionId,
            fieldName: '',
            fieldLabel: '',
            fieldType: '',
            isRequired: 0,
            userIsEditable: 0,
            options: [],
          ),
        );

        fieldsData.add({
          "section_id": sectionId,
          "key": field.fieldName,
          "value": controller.text,
        });
      });

      // Procesar las opciones seleccionadas para cada sección
      TemplateSectionDetails.selectedOptions[sectionId]
          ?.forEach((key, selectedOption) {
        var field = section.templateFields.firstWhere(
          (field) => field.id == key,
          orElse: () => TemplateField(
            id: key,
            sectionId: sectionId,
            fieldName: '',
            fieldLabel: '',
            fieldType: '',
            isRequired: 0,
            userIsEditable: 0,
            options: [],
          ),
        );

        // Aquí buscamos la opción correspondiente para obtener su id
        var selectedOptionId = field.options
            .firstWhere(
              (option) => option.name == selectedOption,
              orElse: () => Option(id: 0, name: ''),
            )
            .id;

        fieldsData.add({
          "section_id": sectionId,
          "key": field.fieldName,
          "value": selectedOptionId ?? 0, // Usamos el id de la opción
        });
      });
      int iFile = 1;
      debugPrint("FilePaths ${TemplateSectionDetails.selectedFiles}");
      debugPrint(
          "FilePaths ${TemplateSectionDetails.selectedFiles[sectionId]}");
      TemplateSectionDetails.selectedFiles[sectionId]?.forEach((key, filePath) {
        var field = section.templateFields.firstWhere(
          (field) => field.id == key,
          orElse: () => TemplateField(
            id: key,
            sectionId: sectionId,
            fieldName: '',
            fieldLabel: '',
            fieldType: 'file', // Indicamos que es un archivo
            isRequired: 0,
            userIsEditable: 0,
            options: [],
          ),
        );

        fieldsData.add({
          "section_id": sectionId,
          "key": field.fieldName,
          "value": "file_${iFile}", // Guardamos la ruta del archivo
        });
        iFile++;
      });
    });

    fieldsData = fieldsData
        .where((item) =>
            item["value"] != null && item["value"].toString().isNotEmpty)
        .toList();

    var body = {"fields": fieldsData};
    print("Cuerpo del Nuevo Post que se envia: ${body["fields"]}");

    return body["fields"]!;
  }

  List<Map<String, dynamic>> viewAllTemplateData() {
    List<Map<String, dynamic>> fieldsData = [];

    // Iteramos por cada sección y sus datos
    TemplateSectionDetails.sections.forEach((sectionId, section) {
      // Procesar los controladores de texto para cada sección
      TemplateSectionDetails.textControllers[sectionId]
          ?.forEach((key, controller) {
        var field = section.templateFields.firstWhere(
          (field) => field.id == key,
          orElse: () => TemplateField(
            id: key,
            sectionId: sectionId,
            fieldName: '',
            fieldLabel: '',
            fieldType: '',
            isRequired: 0,
            userIsEditable: 0,
            options: [],
          ),
        );

        fieldsData.add({
          "section_id": sectionId,
          "key": field.fieldName,
          "value": controller.text,
        });
      });

      // Procesar las opciones seleccionadas para cada sección
      TemplateSectionDetails.selectedOptions[sectionId]
          ?.forEach((key, selectedOption) {
        var field = section.templateFields.firstWhere(
          (field) => field.id == key,
          orElse: () => TemplateField(
            id: key,
            sectionId: sectionId,
            fieldName: '',
            fieldLabel: '',
            fieldType: '',
            isRequired: 0,
            userIsEditable: 0,
            options: [],
          ),
        );
        var selectedOptionName = field.options
            .firstWhere(
              (option) => option.name == selectedOption,
              orElse: () => Option(id: 0, name: ''),
            )
            .name; // Obtenemos el nombre de la opción

        fieldsData.add({
          "section_id": sectionId,
          "key": field.fieldName,
          "value": selectedOptionName, // Usamos el id de la opción
        });
      });
    });

    var body = {"fields": fieldsData};

    print("Cuerpo del View Data: ${body["fields"]}");
    return body["fields"]!;
  }
List<List<String>> getSelectedFilesBySection() {
  List<List<String>> sectionsFiles = [];
  
  // Ordenar las secciones por su ID para mantener consistencia
  var sortedSections = TemplateSectionDetails.selectedFiles.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  
  for (var sectionEntry in sortedSections) {
    List<String> sectionFilePaths = [];
    
    // Ordenar los campos por su ID para mantener consistencia
    var sortedFields = sectionEntry.value.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    for (var fieldEntry in sortedFields) {
      sectionFilePaths.addAll(fieldEntry.value);
    }
    
    if (sectionFilePaths.isNotEmpty) {
      sectionsFiles.add(sectionFilePaths);
    } else {
      // Añadir lista vacía para mantener el orden de las secciones
      sectionsFiles.add([]);
    }
  }
  
  return sectionsFiles;
}

// Para cada sección, obtener sus archivos


  bool validateForm() {
    bool isValid = true;

    TemplateSectionDetails.sections.forEach((sectionId, section) {
      final formKey = TemplateSectionDetails.formKeys[sectionId];
      if (formKey != null && formKey.currentState != null) {
        if (!formKey.currentState!.validate()) {
          isValid = false;
          debugPrint(
              "El formulario de la sección '${section.description}' tiene campos no válidos.");
        }
      } else {
        isValid = false;
        debugPrint(
            "No se encontró una clave de formulario para la sección '${section.description}'.");
      }
      section.templateFields.forEach((field) {
        if (field.fieldType == 'file') {
          final fileSelected =
              TemplateSectionDetails.selectedFiles[sectionId]?[field.id];

          if (fileSelected == null || fileSelected.isEmpty) {
            isValid = false;
            debugPrint(
                "El archivo para el campo '${field.fieldLabel}' en la sección '${section.description}' no ha sido cargado.");
            MessagesToast.showMessageError(
                "El archivo  '${field.fieldLabel}' no ha sido cargado.");
          }
        }
      });
    });

    debugPrint("Validación de formulario: $isValid");
    return isValid;
  }

  void clearForm() {
    TemplateSectionDetails.textControllers.forEach((sectionId, controllers) {
      controllers.forEach((key, controller) {
        controller.clear();
      });
    });

    TemplateSectionDetails.selectedOptions.forEach((sectionId, options) {
      options.clear();
    });

    debugPrint("Formulario limpiado correctamente.");
  }

  String? documentFilePath;

  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : simonGris,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.nameTemplate,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
        ),
        centerTitle: true,
        surfaceTintColor: appStore.isDarkMode ? scaffoldDarkColor : simonGris,
        backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : simonGris,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<TemplateModel>(
        future: _templateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoaderAppIcon());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar la plantilla'));
          } else if (snapshot.hasData) {
            _template = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección Dirección
                    _buildAddressSection(),
                    _buildMultaPorRadar(),

                    if (_template!.templateSections.isNotEmpty)
                      ..._template!.templateSections.map((section) {
                        return _buildTemplateSection(section);
                      }).toList(),
                    if (_template!.templateSections.isEmpty)
                      const Center(
                          child: Text("Este template no tiene secciones.")),
                    /*Row(
                      key: _termsKey,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          activeColor:
                              Colors.green, // Color cuando está marcado
                          onChanged: (bool? value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            "Acepto los términos y condiciones",
                            style: primarytextStyle(size: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),*/
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No se encontró la plantilla'));
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: _sendInfoToGenerateDocument(context),
      ),
    );
  }

  Card _buildMultaPorRadar() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      color: appStore.isDarkMode ? simonGris   : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Radar Movil",
                      style: TextStyle(
                          color: appStore.isDarkMode
                              ? Colors.black
                              : Colors.black)),
                  value: true,
                  groupValue: multaPorRadar,
                  activeColor: simon_finalPrimaryColor,
                  onChanged: (value) {
                    setState(() {
                      multaPorRadar = value!;
                    });
                  },
                ),
                RadioListTile<bool>(
                  title: Text("Radar",
                      style: TextStyle(
                          color: appStore.isDarkMode
                              ? Colors.black
                              : Colors.black)),
                  value: false,
                  contentPadding: EdgeInsets.zero,
                  groupValue: multaPorRadar,
                  activeColor: simonNaranja,
                  onChanged: (value) {
                    setState(() {
                      multaPorRadar = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Positioned(
              top: 5, // Ajusta la posición vertical del ícono
              right: 8, // Ajusta la posición horizontal del ícono
              child: GestureDetector(
                onTap: () {
                  
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const CustomInfoAlert(
                              title: "Ayuda",
                              infoMessage:
                                  "Recuerda que si es radar  móvil, lo que significa que la multa fue emitida en el momento por un agente de tránsito. Suba la imagen mostrada correspondiente a la fotografía tomada durante la infracción.");
                        });
                  
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipPath(
                      clipper: FlagClipper(),
                      child: Container(
                        width: 35,
                        height: 35,
                        color: appStore.isDarkMode ?Colors.white : simonGris,
                      ),
                    ),
                    const Icon(Icons.help_outline,
                        color: simon_finalPrimaryColor, size: 20),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Método para construir la sección de dirección
  Widget _buildAddressSection() {
    return Card(
      color: appStore.isDarkMode ? simonGris : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dirección de Domicilio",
              style: primarytextStyle(
                  color: appStore.isDarkMode
                      ? Colors.black
                      : simon_finalPrimaryColor,
                  size: 17)),
          Container(
              decoration: BoxDecoration(
                color: appStore.isDarkMode ?simonGris : Colors.white,
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                border: Border.all(color: simon_finalPrimaryColor, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                children: [
                  RowInfo(
                      title: "Dirección",
                      data: _selectedAddress?.address ??
                          "No hay dirección registrada"),
                  RowInfo(title: "Provincia", data: "${this.province}"),
                  RowInfo(title: "Ciudad", data: "${this.city}"),
                ],
              )),
        ],
      ).paddingSymmetric(horizontal: 12, vertical: 8),
    ).paddingSymmetric(horizontal: 6);
  }

  // Método para construir las secciones del template
  Widget _buildTemplateSection(TemplateSection section) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.only(bottom: 13),
        child: TemplateSectionDetails(
          section: section,
          isRadar: multaPorRadar,
        ),
      ),
    );
  }

  // Método para crear el botón de enviar
  AppButton _sendInfoToGenerateDocument(BuildContext context) {
    return AppButton(
      width: double.infinity,
      elevation: 4,
      onTap: () async {
        if (!validateForm()) {
          MessagesToast.showMessageError(
              "Hay campos obligatorios sin completar");
          return;
        }

        // 2. Mostrar la pantalla de términos
        bool? acceptedTerms = await TermsScreen().launch(context);
        if (acceptedTerms != true) {
          return; // Si no se aceptan los términos, no continuar
        }

        // 3. Mostrar el diálogo de confirmación
        bool? confirmar = await _showConfirmationDialog(context);
        if (confirmar == true) {
          await generateDocument(_template!.id); // Solo envía si se confirmó
        }
      },
      color: simon_finalPrimaryColor,
      shapeBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Text(
        'Revisar Documento',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Método para mostrar el diálogo de confirmación
  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Para actualizar el estado del checkbox dentro del diálogo
          builder: (context, setState) {
            return AlertDialog(
              titlePadding: const EdgeInsets.all(0),
              title: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                decoration: const BoxDecoration(
                  color: simon_finalPrimaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(DEFAULT_RADIUS),
                    topRight: Radius.circular(DEFAULT_RADIUS),
                  ),
                ),
                child: Text(
                  "Confirmación",
                  style: primarytextStyle(size: 20, color: Colors.white),
                ).center(),
              ),
              titleTextStyle: primaryTextStyle(size: 20, color: Colors.white),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "¿Estás seguro de que deseas enviar los siguientes datos?",
                    textAlign: TextAlign.center,
                    style: primarytextStyle(size: 15, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  ...viewAllTemplateData().map((data) {
                    return _buildDialogDataRow(data);
                  }).toList(),
                  const SizedBox(height: 16),

                  // Checkbox para aceptar términos y condiciones
                  Text(
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    "Ha aceptado los términos y condiciones",
                    style: primarytextStyle(size: 14, color: Colors.black),
                  ).center(),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Cancelar",
                      style: TextStyle(color: simon_finalPrimaryColor)),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: simon_finalPrimaryColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  }, // Si no acepta, el botón queda deshabilitado
                  child: const Text("Enviar",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método para construir cada fila de datos en el diálogo
  Widget _buildDialogDataRow(Map<String, dynamic> data) {
    final sectionName =
        TemplateSectionDetails.sections[data["section_id"]]!.name ??
            "Sección desconocida";
    String fieldLabel = data["key"];

    TemplateSectionDetails.sections[data["section_id"]]!.templateFields
        .forEach((field) {
      if (field.fieldName == data["key"]) {
        fieldLabel = field.fieldLabel;
      }
    });

    return !fieldLabel.contains("Archivo")
        ? RichText(
            text: TextSpan(
              text: "$fieldLabel: ",
              style: const TextStyle(
                  color: simon_finalPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w400),
              children: <TextSpan>[
                TextSpan(
                  text: data["value"],
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
