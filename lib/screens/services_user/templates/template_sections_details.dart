import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:simon_final/components/simon/alert_dialog.dart';
import 'package:simon_final/components/simon/text_form_field_simon.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/template_model.dart';
import 'package:simon_final/models/vehicle_document_user.dart';
import 'package:simon_final/screens/documents_user/view_docs/docs_vehicle_Associated_screen.dart';
import 'package:simon_final/screens/legends_uploads_information/camera_screen.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/vehicles_user_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:ionicons/ionicons.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TemplateSectionDetails extends StatefulWidget {
  final TemplateSection section;
  final bool? isRadar;

  static Map<int, Map<int, TextEditingController>> textControllers = {};
  static Map<int, Map<int, String?>> selectedOptions = {};
  static Map<int, TemplateSection> sections = {};
  static Map<int, GlobalKey<FormState>> formKeys = {};
  static Map<int, Map<int, List<String>>> selectedFiles =
      {}; // Cambiamos a dynamic para soportar List<String> o String

  TemplateSectionDetails(
      {super.key, required this.section, this.isRadar = false}) {
    sections[section.id] = section;
    textControllers.putIfAbsent(
        section.id, () => {}); // Inicializa el mapa interno
    selectedOptions.putIfAbsent(section.id, () => {});
    formKeys[section.id] = GlobalKey<FormState>();
  }

  static late TemplateSection selectedSection;

  @override
  State<TemplateSectionDetails> createState() => _TemplateSectionDetailsState();
}

class _TemplateSectionDetailsState extends State<TemplateSectionDetails> {
  List<VehicleDocumentTypeModel> documents = [];
  final vehicleServices = VehiclesUserServices();
  bool isWithPhoto = false;
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    widget.section.templateFields.forEach((field) {
      if (field.fieldType != 'model') {
        TemplateSectionDetails.textControllers[widget.section.id]!.putIfAbsent(
          field.id,
          () => TextEditingController(),
        );
      } else if (field.fieldType == 'file') {
        TemplateSectionDetails.selectedFiles
            .putIfAbsent(widget.section.id, () => {});
        TemplateSectionDetails.selectedFiles[widget.section.id]!
            .putIfAbsent(field.id, () => []);
      }
    });
    final userProvider = context.read<UserProvider>();
    Provider.of<VehicleProvider>(context, listen: false)
        .fetchVehicles(userProvider.user.id, userProvider.currentProfile);

    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  String _getLastFileName(int sectionId, int fieldId) {
    final files = TemplateSectionDetails.selectedFiles[sectionId]?[fieldId];
    if (files == null || files.isEmpty) return "Ningún archivo seleccionado";

    final fullPath = files.last;
    final fileName = fullPath.split('/').last;
    return fileName.length > 20 ? '${fileName.substring(0, 15)}...' : fileName;
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: simon_finalPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
              ),
              headerForegroundColor: Colors.white,
              headerHelpStyle: const TextStyle(fontSize: 16),
            ),
            primarySwatch: Colors.grey,
            splashColor: Colors.white,
            textTheme: const TextTheme(
              headlineLarge: TextStyle(color: Colors.black),
            ),
            colorScheme: const ColorScheme.light(
              primary: simon_finalPrimaryColor,
              onSecondary: Colors.black,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child ?? const Text(""),
        );
      },
      locale: const Locale('es'),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      helpText: "Selecciona una fecha para la citacion",
      cancelText: "Cancelar",
      confirmText: "Aceptar",
    );

    if (picked != null) {
      // Verificar si la fecha seleccionada es menos de 3 días antes de la fecha actual
      DateTime today = DateTime.now();
      DateTime threeDaysAgo = today.subtract(const Duration(days: 3));

      if (picked != null) {
        // Obtener la fecha actual
        DateTime today = DateTime.now();

        // Verificar si la fecha seleccionada es 3 o más días antes de la fecha actual
        Duration difference = today.difference(picked);

        if (difference.inDays >= 3) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomAlertDialog(
                textButton: "Entendido",
                iconData: Icons.warning,
                title: "Advertencia",
                content: "No se asegura la efectividad de la impugnación.",
                withRedirection: false,
                onPressedRoute: () {
                  Navigator.pop(context);
                },
              );
            },
          );
          controller.text =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        } else {
          // Si la fecha es válida (menos de 3 días antes de la fecha actual), actualizar el controlador
          controller.text =
              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        }
      }
    }
  }

  Future<String?> _selectFileForField(
      String field, List<String> extensions) async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: extensions);

      if (result != null) {
        MessagesToast.showMessageInfo(
            "Archivo seleccionado para $field: ${result.files.single.name}");
        return result.files.single.path;
      } else {
        MessagesToast.showMessageInfo(
            "Selección de archivo cancelada para $field");
        throw Exception("Selección de archivo cancelada para $field");
      }
    } catch (e) {
      /* MessagesToast.showMessageError(
          "Error al seleccionar archivo para $field: $e");*/
      throw Exception("Error al seleccionar archivo para $field: $e");
    }
  }

  Future<void> _selectMultiplePhotos(TemplateField field) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          TemplateSectionDetails.selectedFiles
              .putIfAbsent(widget.section.id, () => {});
          TemplateSectionDetails.selectedFiles[widget.section.id]![field.id] =
              result.files.map((file) => file.path!).toList();
        });
      }
    } catch (e) {
      MessagesToast.showMessageError("Error al seleccionar fotos: $e");
    }
  }

  Future<String?> _navigateToCameraScreen(String nameDocument) async {
    final imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          largeDocument: true,
          nameDocument: nameDocument,
        ),
      ),
    );

    return imagePath; // Devuelve la ruta de la imagen tomada
  }

  Future<void> _takePhoto(BuildContext context, TemplateField field) async {
    final imagePath = await _navigateToCameraScreen(field.fieldLabel);

    if (imagePath != null) {
      setState(() {
        this.isWithPhoto = true;
        // Inicializar si no existe
        TemplateSectionDetails.selectedFiles
            .putIfAbsent(widget.section.id, () => {});
        TemplateSectionDetails.selectedFiles[widget.section.id]!
            .putIfAbsent(field.id, () => []);

        // Agregar la nueva foto
        TemplateSectionDetails.selectedFiles[widget.section.id]![field.id]!
            .add(imagePath);
      });
    }
  }

  void _showFilePickerModal(
      BuildContext context, String nameDocument, TemplateField field) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Selecciona una opción",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: appStore.isDarkMode
                            ? scaffoldLightColor
                            : Colors.black)),
                const SizedBox(height: 10),

// Opción para tomar foto (solo si isRadar es true)
                if (widget.isRadar == true)
                  ListTile(
                    leading: const Icon(Icons.camera_alt,
                        color: simon_finalPrimaryColor),
                    title: Text("Tomar foto",
                        style: TextStyle(
                            color: appStore.isDarkMode
                                ? scaffoldLightColor
                                : Colors.black)),
                    onTap: () async {
                   //   Navigator.pop(context); // Cierra el modal
                     // await _takePhoto(context, field);
              
                      showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomAlertDialog(
                          iconData: Icons.check_circle,
                          textButton: "Entendido",
                          withRedirection: false,
                          title: "Importante",
                          content:
                              "Para garantizar un proceso exitoso, las imágenes tomadas  deben ser de  calidad. Asegúrate de que sean nítidos y legibles, ya que imágenes borrosas o de baja resolución podrían afectar la validez de la impugnación",
                          onPressedRoute: () async {
                            Navigator.pop(context); // Cerrar modal
                            Navigator.pop(context); // Cerrar modal
                             await _takePhoto(context, field);
                          },
                        );
                      });
                    },
                  ),

// Opción para subir un PDF (por defecto si isRadar es false o null)
                ListTile(
                  leading:
                      const Icon(Icons.picture_as_pdf, color: simonNaranja),
                  title: Text(
                    "Subir PDF",
                    style: TextStyle(
                        color: appStore.isDarkMode
                            ? scaffoldLightColor
                            : Colors.black),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    List<String> fileExtensions = ['pdf'];
                    try {
                      String? filePath = await _selectFileForField(
                          nameDocument, fileExtensions);
                      if (filePath != null) {
                        setState(() {
                          this.isWithPhoto = false;
                          TemplateSectionDetails.selectedFiles.putIfAbsent(
                              widget.section.id,
                              () => {}); // Asegurar que la clave existe
                          TemplateSectionDetails
                              .selectedFiles[widget.section.id]![field.id] = [
                            filePath
                          ];
                        });
                      }
                    } catch (e) {
                      /*MessagesToast.showMessageError("Error al seleccionar archivo: $e");*/
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _validateVehicleDocuments(String selectedPlate) async {
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    final userProvider = context.read<UserProvider>();

    final selectedVehicle = vehicleProvider.vehicleList.firstWhere(
      (vehicle) => vehicle.plateNumber == selectedPlate,
    );
    await _fetchVehicleDocuments(selectedVehicle.id ?? 0, userProvider.user.id,
        userProvider.currentProfile);

    final hasDocuments = documents.isNotEmpty;

    for (final document in documents) {
      if (document.vehicleDocument == null) {
        _showUploadDocumentByCar(context, selectedVehicle.id ?? 0);
        break;
      }
    }

    if (!hasDocuments) {
      _showUploadDocumentByCar(context, selectedVehicle.id ?? 0);
    }
  }

  Future<void> _fetchVehicleDocuments(
      int vehicleId, int userId, int profileId) async {
    try {
      documents = await vehicleServices.getVehicleDocumentTypes(
          vehicleId, userId, profileId);
    } catch (e) {
      debugPrint("Error al cargar los documentos del usuario");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 2,
      color: appStore.isDarkMode ? simonGris : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Form(
        key: TemplateSectionDetails.formKeys[widget.section.id],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.section.templateFields.isNotEmpty) ...[
              ...widget.section.templateFields.map((field) {
                bool isVechicle = false;
                if (field.fieldName == "VEHICLE") {
                  isVechicle = true;
                }
                if (field.fieldType == 'model') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize
                                .min, // Ajusta el tamaño al contenido
                            children: [
                              Text(
                                field.fieldLabel,
                                style: primarytextStyle(
                                  color: appStore.isDarkMode
                                      ? Colors.black
                                      : simon_finalPrimaryColor,
                                  size: 17,
                                ),
                              ),
                              const Text(
                                "*",
                                style: TextStyle(
                                    fontSize: 16, color: simonNaranja),
                              ).paddingSymmetric(horizontal: 2),
                            ],
                          ),
                          field.description != null
                              ? GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomInfoAlert(
                                              title:
                                                  "${field.fieldLabel}  Ayuda",
                                              infoMessage: field.description ??
                                                  "No hay una descripcion asisganada aun ");
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
                                          color: simon_finalPrimaryColor,
                                          size: 20),
                                    ],
                                  ))
                              : const SizedBox.shrink()
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: simon_finalPrimaryColor, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                          
                              hintStyle: const TextStyle(
                                  fontSize: 16, color: resendColor),
                              hintText:
                                  "${isVechicle ? 'Selecciona tu' : 'Selecciona la'} ${field.fieldLabel}",
                              prefixIcon: isVechicle
                                  ? const Icon(
                                      Ionicons.car,
                                      color: simon_finalPrimaryColor,
                                    )
                                  : const Icon(
                                      Icons.business,
                                      color: simon_finalPrimaryColor,
                                    )),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "${field.fieldLabel} es requerido";
                            }
                            return null;
                          },
                          
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.white),
                          iconEnabledColor: Colors.black,
                          isExpanded: true,
                          value: TemplateSectionDetails
                              .selectedOptions[widget.section.id]![field.id],
                          onChanged: (String? newValue) {
                            setState(() {
                              TemplateSectionDetails.selectedOptions[
                                  widget.section.id]![field.id] = newValue;
                              if (field.fieldName == "VEHICLE") {
                                _validateVehicleDocuments(newValue!);
                              }
                            });
                          },
                          items: field.options
                              .map<DropdownMenuItem<String>>((Option option) {
                            return DropdownMenuItem<String>(
                              value: option.name,
                              child: Text(option.name,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16)),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 1),
                    ],
                  ).paddingSymmetric(horizontal: 8);
                } else if (field.fieldType == "file") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      TemplateSectionDetails.selectedFiles[widget.section.id]
                                  ?[field.id] !=
                              null
                          ? (widget.isRadar == false ||
                                  this.isWithPhoto == false)
                              ? Container(
                                  height: size.height * 0.14,
                                  width: size.width,
                                  padding: EdgeInsets.all(size.width * 0.03),
                                  decoration: BoxDecoration(
                                    color: simon_finalSecondaryColor,
                                    borderRadius:
                                        BorderRadius.circular(DEFAULT_RADIUS),
                                    border: Border.all(
                                        color: borderColor, width: 2),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  field.fieldLabel,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                ),
                                                Text(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  _getLastFileName(
                                                      widget.section.id,
                                                      field.id),
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child:
                                                          LinearProgressIndicator(
                                                        minHeight: 10,
                                                        value: 1.0,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                DEFAULT_RADIUS),
                                                        backgroundColor:
                                                            Colors.white,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                                    Color>(
                                                                simon_finalPrimaryColor),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                        Icons.check_circle,
                                                        color:
                                                            simon_finalPrimaryColor),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: simonNaranja),
                                            onPressed: () {
                                              setState(() {
                                                TemplateSectionDetails
                                                    .selectedFiles[
                                                        widget.section.id]
                                                    ?.remove(field.id);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : Column(children: [
                                  AppButton(
                                    width: double.infinity,
                                    color: simon_finalPrimaryColor,
                                    shapeBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            DEFAULT_RADIUS)),
                                    onTap: () async {
                                       await _takePhoto(context, field);
                                    },
                                    child: Text(
                                      "Agregar otra foto",
                                      style: primarytextStyle(
                                          size: 13, color: Colors.white),
                                    ),
                                  ).paddingSymmetric(
                                      vertical: 5, horizontal: 8),
                                  SizedBox(
                                    height: 600,
                                    width: 350,
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: TemplateSectionDetails
                                          .selectedFiles[widget.section.id]![
                                              field.id]!
                                          .length,
                                      itemBuilder: (context, index) {
                                        final image = TemplateSectionDetails
                                                .selectedFiles[
                                            widget
                                                .section.id]![field.id]![index];
                                        return Stack(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(),
                                                borderRadius: BorderRadius.circular(
                                                    12), // Bordes redondeados opcionales
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(
                                                    12), // Asegura que la imagen siga el borde redondeado
                                                child: Image.file(
                                                  File(image),
                                                  fit: BoxFit.cover,
                                                  width: double
                                                      .infinity, // Para que respete el contenedor
                                                  height: double.infinity,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: IconButton(
                                                icon: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        simonNaranja, // Fondo naranja
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.white),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    TemplateSectionDetails
                                                        .selectedFiles[widget
                                                            .section
                                                            .id]![field.id]!
                                                        .removeAt(index);
                                                    if (TemplateSectionDetails
                                                        .selectedFiles[widget
                                                            .section
                                                            .id]![field.id]!
                                                        .isEmpty) {
                                                      TemplateSectionDetails
                                                          .selectedFiles[widget
                                                              .section.id]!
                                                          .remove(field.id);
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              left: 0,
                                              right: 0,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 20),
                                                child: Center(
                                                  child: SmoothPageIndicator(
                                                    controller: _pageController,
                                                    count:
                                                        TemplateSectionDetails
                                                            .selectedFiles[
                                                                widget.section
                                                                    .id]![
                                                                field.id]!
                                                            .length,
                                                    effect: const WormEffect(
                                                      activeDotColor:
                                                          simon_finalPrimaryColor,
                                                      dotColor: Colors.grey,
                                                      dotHeight: 8,
                                                      dotWidth: 8,
                                                      spacing: 5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ])
                          : GestureDetector(
                              onTap: () async {
                                _showFilePickerModal(
                                    context, field.fieldLabel, field);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(DEFAULT_RADIUS),
                                  border: Border.all(
                                      color: simon_finalPrimaryColor, width: 2),
                                ),
                                width: size.width * 0.9,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Ionicons.cloud_upload_outline,
                                      color: simon_finalPrimaryColor,
                                      size: size.width * 0.1,
                                    ),
                                    Text(
                                      "Toque para subir ${field.fieldLabel}",
                                      style: const TextStyle(
                                          color: simon_finalPrimaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ).center(),
                                  ],
                                ).paddingSymmetric(vertical: 3),
                              ).paddingSymmetric(horizontal: 8),
                            ),
                    ],
                  ).paddingSymmetric(vertical: 8);
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize
                                .min, // Ajusta el tamaño al contenido
                            children: [
                              Text(
                                field.fieldLabel,
                                style: primarytextStyle(
                                  color: appStore.isDarkMode
                                      ? Colors.black
                                      : simon_finalPrimaryColor,
                                  size: 17,
                                ),
                              ),
                              const Text(
                                "*",
                                style: TextStyle(
                                    fontSize: 16, color: simonNaranja),
                              ).paddingSymmetric(horizontal: 2),
                            ],
                          ),
                          field.description != null
                              ? GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomInfoAlert(
                                              title:
                                                  "${field.fieldLabel} Ayuda",
                                              infoMessage: field.description ??
                                                  "No hay una descripcion asisganada aun ");
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
                                          color: appStore.isDarkMode ? Colors.white : simonGris,
                                        ),
                                      ),
                                      const Center(
                                        child: Icon(Icons.help_outline,
                                            color: simon_finalPrimaryColor,
                                            size: 20),
                                      ),
                                    ],
                                  ))
                              : const SizedBox.shrink(),
                        ],
                      ).paddingBottom(5),
                      field.fieldType == "text"
                          ? TextFormFieldSimon(
                              icon: Icons.assignment,
                              moreAjusted: false,
                              fillColor: Colors.white,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '${field.fieldLabel} es requerido';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.text,
                              hintText:
                                  'Ingrese ${field.fieldLabel.toLowerCase()}',
                              controller: TemplateSectionDetails
                                          .textControllers[widget.section.id]
                                      ?[field.id] ??
                                  TextEditingController(),
                              textCapitalization: TextCapitalization.characters,
                            )
                          : TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "${field.fieldLabel} es requerido";
                                }
                              },
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(color: resendColor),
                                fillColor: Colors.white,
                                prefixIcon: const Icon(
                                  Icons.calendar_today,
                                  color: simon_finalPrimaryColor,
                                ),
                                filled: true,
                                hintText:
                                    'Ingrese ${field.fieldLabel.toLowerCase()}',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: borderColor, width: 1),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: simonNaranja, width: 1),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: simon_finalPrimaryColor, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: simon_finalPrimaryColor, width: 1),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                      color: resendColor, width: 1),
                                ),
                              ),
                              controller: TemplateSectionDetails
                                          .textControllers[widget.section.id]
                                      ?[field.id] ??
                                  TextEditingController(),
                              readOnly: true,
                              onTap: () => _selectDate(
                                context,
                                TemplateSectionDetails.textControllers[
                                    widget.section.id]![field.id]!,
                              ),
                            ),
                      const SizedBox(height: 16),
                    ],
                  ).paddingSymmetric(horizontal: 8);
                }
              }).toList(),
            ],
            if (widget.section.templateFields.isEmpty)
              const Text("No hay template_fields.",
                  style: TextStyle(fontSize: 16)),
          ],
        ).paddingSymmetric(horizontal: 8, vertical: 8),
      ),
    ).paddingSymmetric(horizontal: 8);
  }
}

void _showUploadDocumentByCar(BuildContext context, int selectedVehicleId) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CustomAlertDialog(
        iconData: Icons.info,
        title: "!Importante!",
        content:
            "Debes subir los documentos del auto para generar el documento.",
        withRedirection: true,
        route: Routes.docsVehiculo,
        onPressedRoute: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => DocsVehicleAssociatedScreen(
                      idSelectedVehicle: selectedVehicleId)));
        },
      );
    },
  );
}

class FlagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width, 0); // Empieza en la esquina superior derecha
    path.lineTo(size.width * 0.3,
        0); // Avanza al 30% del ancho (inicio de la punta izquierda)
    path.lineTo(0, size.height / 2); // Punta izquierda (centro vertical)
    path.lineTo(
        size.width * 0.3, size.height); // Baja recto hasta el 30% del ancho
    path.lineTo(size.width, size.height); // Esquina inferior derecha
    path.close(); // Cierra el camino (sin triángulo interno)
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
// /
