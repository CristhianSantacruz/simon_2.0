import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simon_final/components/simon/alert_dialog.dart';
import 'package:simon_final/components/simon/custom_alert_dialog_with_actions.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/user_document_type_model.dart';
import 'package:simon_final/models/vehicle_document_user.dart';
import 'package:simon_final/providers/page_controller_provider.dart';
import 'package:simon_final/screens/legends_uploads_information/camera_screen.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/user_documents_types.services.dart';
import 'package:simon_final/services/vehicles_user_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';

class UploadUserDocumentation extends StatefulWidget {
  final String name;
  final int idDocument;
  final bool? isOne;
  final bool? onlyMatricula;
  final int? idVehicle;
  final UserDocumentTypeModel? userDocumentType;
  final VehicleDocumentTypeModel? vehicleDocumentType;

  const UploadUserDocumentation(
      {super.key,
      required this.name,
      required this.idDocument,
      this.onlyMatricula = false,
      this.idVehicle,
      this.userDocumentType,
      this.vehicleDocumentType,
      this.isOne = false});

  @override
  State<UploadUserDocumentation> createState() =>
      _UploadUserDocumentationState();
}

class _UploadUserDocumentationState extends State<UploadUserDocumentation> {
  final TextEditingController documentController = TextEditingController();
  String? documentFilePath;
  String? secondDocumentFilePath;
  String? documentFileName = "";
  final userDocuments = UserDocumentsTypesServices();
  final _formKey = GlobalKey<FormState>();
  final vehicleServices = VehiclesUserServices();
  double _valueIndicator = 0.1;
  bool withDateExpiration = false;
  bool _isDocumentVehicle = false;
  bool _isUploading = false;
  bool _isWithPhoto = false;

  bool reverseIsRequired = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    debugPrint("Documento que vamos a subir datos ${widget.idDocument}");

    withDateExpiration = widget.name == "Cedula";
    _isDocumentVehicle = widget.name == "Matricula";

    if (widget.userDocumentType != null) {
      debugPrint("Documento ${widget.userDocumentType!.toJson()}");
      reverseIsRequired = widget.userDocumentType!.required2 != 0;
    }

    if (widget.vehicleDocumentType != null) {
      reverseIsRequired = widget.vehicleDocumentType!.required2 != 0;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isDocumentVehicle) {
        final vehicleProvider =
            Provider.of<VehicleProvider>(context, listen: false);
        await vehicleProvider.fetchVehicles(
            userProvider.user.id, userProvider.currentProfile);

        if (vehicleProvider.vehicleList.isNotEmpty) {
          reverseIsRequired = await isRequiredReverdeDocumentVehicle(
            userProvider.user.id,
            vehicleProvider.vehicleList.last.id!,
            userProvider.currentProfile,
          );
        } else {
          MessagesToast.showMessageInfo("No hay vehículos registrados.");
        }
      } else {
        // Si NO es un vehículo, verificar si required2 es necesario
        reverseIsRequired = await isReverseRequired(widget.idDocument,
            userProvider.user.id, userProvider.currentProfile);
      }

      setState(() {}); // Actualizar la UI después de obtener los valores
    });
  }

  @override
  void dispose() {
    // _cameraController.dispose();
    super.dispose();
  }

  Future<bool> isReverseRequired(
      int idDocument, int userId, int profileId) async {
    try {
      final userDocumentType =
          await userDocuments.getUserDocumentsTypes(userId, profileId);
      return userDocumentType
              .where((element) => element.id == idDocument)
              .first
              .required2 !=
          0;
    } catch (e) {
      debugPrint("Error al cargar el tipo de documento: $e");
      return false; // En caso de error, asumimos que no es requerido
    }
  }

  Future<bool> isRequiredReverdeDocumentVehicle(
      int userId, int vehicleId, int profileId) async {
    debugPrint("Verificando si es requerido el documento de vehículo");
    try {
      List<VehicleDocumentTypeModel> documentsVehicle = await vehicleServices
          .getVehicleDocumentTypes(vehicleId, userId, profileId);

      print("Documentos obtenidos: $documentsVehicle");

      if (documentsVehicle.isNotEmpty) {
        bool allRequired2 =
            documentsVehicle.every((element) => element.required2 == 1);
        print("Todos los documentos tienen required2 == 1? $allRequired2");
        return allRequired2;
      }

      print("No hay documentos registrados.");
      return false;
    } catch (e) {
      debugPrint("Error al cargar los documentos del vehículo: $e");
      return false;
    }
  }

  Future<void> _navigateToCameraScreen(int numberDocument) async {
    final imagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          nameDocument: widget.name,
          textButtonPhoto:
              numberDocument == 1 ? "Tomar Foto Frontal" : "Tomar Foto Trasera",
        ),
      ),
    );

    if (imagePath != null) {
      setState(() {
        if (numberDocument == 1) {
          documentFilePath = imagePath;
          debugPrint("El documento frontal: $documentFilePath");
        } else {
          secondDocumentFilePath = imagePath;
          debugPrint("El documento trasero: $secondDocumentFilePath");
        }
        _isWithPhoto = true;
      });

      // Verificar si se debe tomar la foto trasera automáticamente
      if (numberDocument == 1) {
        if (this.reverseIsRequired == true) {
          await Future.delayed(const Duration(
              milliseconds: 500)); // Pequeña pausa antes de redirigir
          _navigateToCameraScreen(
              2); // Llamar a la cámara para la parte trasera
        }
      }
    }
  }

  void submitDocument(
    String nameDocument,
    String vehicleDocumentFilePath,
    int userId,
    int profileId,
    int vehicleDocumentTypeId,
    String expirationDate,
    String? secondDocumentFilePath,
  ) async {
    final vehicleProvider =
        Provider.of<VehicleProvider>(context, listen: false);
    await vehicleProvider.fetchVehicles(userId, profileId);
    if (vehicleProvider.vehicleList.isNotEmpty) {
      final firstVehicle = vehicleProvider.vehicleList.last;
      final vehicleIdLast = firstVehicle.id!;
      final selectedVehicleId =
          widget.onlyMatricula == true ? widget.idVehicle : vehicleIdLast;
      vehicleServices
          .uploadVehiculeDocument(
        nameDocument,
        vehicleDocumentFilePath,
        secondDocumentFilePath,
        userId,
        selectedVehicleId!,
        profileId,
        vehicleDocumentTypeId,
      )
          .then((value) async {
        MessagesToast.showMessageSuccess("Documento subido correctamente");
        showCustomAlertImpugnar(context);
      }).catchError((error) {
        toast("Error al enviar el documento");
      });
    } else {
      toast("No hay vehículos registrados.");
    }
  }

  void showCustomAlertImpugnar(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomAlertDialogWithActions(
          title: "!Perfecto!",
          content: "Ya tienes los requesitos necesarios para impugnar ",
          contentQuestion: "¿Deseas impugnar ahora?",
          onAccept: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, Routes.impugnaMultas);
            print("Aceptar presionado");
          },
          onCancel: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, Routes.dashboard);
            print("No presionado");
          },
        );
      },
    );
  }

  Future<void> _selectFileForField(
      String field, List<String> extensions, int frontalOrReverse) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );
      if (result != null) {
        if (frontalOrReverse == 1) {
          setState(() {
            documentFilePath = result.files.single.path;
            documentFileName = result.files.single.name;
            _valueIndicator = 1;
          });
          toast(
              "Archivo seleccionado para $field: ${result.files.single.name}");
        } else {
          setState(() {
            secondDocumentFilePath = result.files.single.path;
            _valueIndicator = 1;
          });
          toast(
              "Archivo seleccionado para $field: ${result.files.single.name}");
        }

        toast("Archivo seleccionado para $field: ${result.files.single.name}");
      } else {
        toast("Selección de archivo cancelada para $field");
      }
    } catch (e) {
      toast("Error al seleccionar archivo para $field: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final providerDocuments = Provider.of<DocumentUserProvider>(context);
    final providerUser = Provider.of<UserProvider>(context);
    final pageControllerProvider = Provider.of<PageControllerProvider>(context);
    return !_isUploading
        ? SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  left: size.width * 0.05,
                  right: size.width * 0.05,
                  bottom: size.height * 0.05), // Padding responsivo
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isDocumentVehicle == false
                      ? Text(
                          "Sube tu ${widget.name} sin problemas para realizar tus tramites en todo momento",
                          style:
                              const TextStyle(fontSize: 13, color: resendColor),
                          textAlign: TextAlign.center,
                        ).center()
                      : const SizedBox.shrink(),

                  // Cuadro que indica que se suba la imagen
                  if (documentFilePath != null &&
                      documentFilePath!.split('.').last.toLowerCase() != 'pdf')
                    reverseIsRequired
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (secondDocumentFilePath == null)
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(DEFAULT_RADIUS),
                                    ),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _modalUploadDocument(context, 2);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flash(
                                        duration: const Duration(seconds: 3),
                                        infinite: true,
                                        child: const Icon(
                                          Icons.circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      5.width,
                                      const Text("Subir (Parte Trasera)"),
                                    ],
                                  ),
                                ),
                            ],
                          ).paddingSymmetric(vertical: 1)
                        : const SizedBox.shrink(),

                  documentFilePath == null
                      ? GestureDetector(
                          onTap: () {
                            _modalUploadDocument(context, 1);
                          },
                          child: DottedBorderWidget(
                            strokeWidth: 2,
                            dotsWidth: 10,
                            color: simonNaranja,
                            radius: DEFAULT_RADIUS,
                            gap: 10,
                            child: Container(
                              height: size.height * 0.23,
                              width: size.width * 0.9,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flash(
                                    infinite: true,
                                    duration: const Duration(seconds: 4),
                                    child: Icon(
                                      Ionicons.cloud_upload_outline,
                                      color: simonNaranja,
                                      size: size.width * 0.1,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    textAlign: TextAlign.center,
                                    "Toque para subir la ${widget.name} Frontal",
                                    style: TextStyle(
                                        color: appStore.isDarkMode
                                            ? scaffoldLightColor
                                            : Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700),
                                  ).center(),
                                  2.height,
                                  Text(
                                    "Frontal",
                                    style: TextStyle(
                                        color: appStore.isDarkMode
                                            ? scaffoldLightColor
                                            : Colors.black54,
                                        fontSize: 12),
                                  ).center(),
                                  2.height,
                                  Text(
                                    "JPG,PNG,PDF fomato",
                                    style: TextStyle(
                                        color: appStore.isDarkMode
                                            ? scaffoldLightColor
                                            : Colors.black54,
                                        fontSize: 12),
                                  ).center(),
                                ],
                              ),
                            ),
                          ),
                        ).paddingSymmetric(vertical: 13)
                      : documentFilePath!.split('.').last.toLowerCase() != 'pdf'
                          ? _buildImage(size, "Frontal", documentFilePath)
                          : Column(
                              children: [
                                Container(
                                  height: size.height * 0.11,
                                  width: size.width * 0.9,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.04,
                                      vertical: size.height * 0.01),
                                  decoration: BoxDecoration(
                                    color: simon_finalSecondaryColor,
                                    borderRadius:
                                        BorderRadius.circular(DEFAULT_RADIUS),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        "${documentFilePath?.split('/').last ?? ""}",
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.black),
                                      ),
                                      const SizedBox(height: 10),
                                      // Barra de carga
                                      LinearProgressIndicator(
                                        value: 1,
                                        minHeight: 10,
                                        borderRadius: BorderRadius.circular(
                                            DEFAULT_RADIUS),
                                        backgroundColor:
                                            Colors.blue.withOpacity(0.3),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                simon_finalPrimaryColor),
                                      ),
                                      const SizedBox(height: 10),
                                      documentFilePath != null
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const Icon(
                                                  Ionicons.checkmark_circle,
                                                  color:
                                                      simon_finalPrimaryColor,
                                                  size: 20,
                                                ),
                                                5.width,
                                                const Text(
                                                  "Documento cargado correctamente.",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black),
                                                ),
                                              ],
                                            )
                                          : const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Sube tu imagen ",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black),
                                                ),
                                                Icon(
                                                  Ionicons.information,
                                                  color: Colors.black,
                                                  size: 20,
                                                )
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                const Icon(
                                  FontAwesomeIcons.filePdf,
                                  size: 50,
                                  color: simon_finalPrimaryColor,
                                )
                              ],
                            ),

                  //  SizedBox(height: 20),

                  secondDocumentFilePath != null
                      ? _buildImage(
                          size, "Parte trasera", secondDocumentFilePath)
                      : const SizedBox(),

                  const SizedBox(height: 30),
                  /* documentFilePath == null
                      ? AppButton(
                          width: size.width * 0.8,
                          elevation: 2,
                          onTap: () {
                            //_checkAndRequestPermissions();
                            // _takePhoto();
                            _navigateToCameraScreen(1);
                          },
                          color: Colors.white,
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                            side: BorderSide(
                                color: simon_finalPrimaryColor, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_camera,
                                  color: simon_finalPrimaryColor, size: 25),
                              10.width,
                              Text(
                                'Tomar una foto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: simon_finalPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ).paddingSymmetric(vertical: 5)
                      : SizedBox(),*/
                  // Botón de confirmar subida

                  documentFilePath != null || secondDocumentFilePath != null
                      ? AppButton(
                          width: size.width * 0.8,
                          elevation: 2,
                          onTap: () {
                            setState(() {
                              documentFilePath = null;
                              secondDocumentFilePath = null;
                            });
                          },
                          color: simonNaranja,
                          shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete,
                                  color: Colors.white, size: 25),
                              10.width,
                              const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ).paddingSymmetric(vertical: 5)
                      : const SizedBox(),

                  AppButton(
                    width: size.width * 0.8,
                    elevation: 2,
                    onTap: () {
                      if (reverseIsRequired == true &&
                          secondDocumentFilePath == null &&
                          (documentFilePath!.split('.').last.toLowerCase() !=
                              'pdf')) {
                        MessagesToast.showMessageInfo(
                            "Debe tener el documento reverso");
                        return;
                      }

                      if (_isDocumentVehicle) {
                        if (withDateExpiration) {
                          if (_formKey.currentState!.validate() &&
                              documentFilePath != null) {
                            submitDocument(
                                widget.name,
                                documentFilePath ?? '',
                                providerUser.user.id,
                                providerUser.currentProfile,
                                widget.idDocument,
                                withDateExpiration
                                    ? documentController.text
                                    : "",
                                secondDocumentFilePath);
                          } else if (documentFilePath == null) {
                            MessagesToast.showMessageInfo(
                                "Suba una imagen porfavor");
                          } else if (withDateExpiration) {
                            MessagesToast.showMessageInfo(
                                "Ingresa la fecha de expiración porfavor");
                          }
                        } else {
                          if (documentFilePath != null) {
                            submitDocument(
                                widget.name,
                                documentFilePath ?? '',
                                providerUser.user.id,
                                providerUser.currentProfile,
                                widget.idDocument,
                                withDateExpiration
                                    ? documentController.text
                                    : "",
                                secondDocumentFilePath);
                          } else if (documentFilePath == null) {
                            MessagesToast.showMessageInfo(
                                "Suba una imagen porfavor");
                          }
                        }
                      } else {
                        if (documentFilePath != null) {
                          setState(() {
                            _isUploading = true;
                          });
                          providerDocuments
                              .uploadDocument(
                                  widget.name,
                                  documentFilePath!,
                                  widget.idDocument,
                                  withDateExpiration ? "" : null,
                                  providerUser.user.id,
                                  secondDocumentFilePath,
                                  providerUser.currentProfile)
                              .then((_) {
                            setState(() {
                              _isUploading = false;
                            });
                            if (widget.isOne == true) {
                              Navigator.pushReplacementNamed(
                                  context, Routes.dashboard);
                            } else if (pageControllerProvider.isLastPage()) {
                              Navigator.pushReplacementNamed(
                                  context, Routes.dashboard);
                            } else {
                              pageControllerProvider.nextPage();
                            }
                          });
                        } else if (documentFilePath == null) {
                          MessagesToast.showMessageInfo(
                              "Suba una imagen porfavor");
                        }
                      }
                    },
                    color: simon_finalPrimaryColor,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Ionicons.checkmark_circle,
                            color: Colors.white, size: 25),
                        10.width,
                        const Text(
                          'Confirmar Subida',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  12.height,
                  Text(
                    "Requerimientos",
                    style: primaryTextStyle(
                        color: appStore.isDarkMode
                            ? scaffoldLightColor
                            : Colors.black,
                        size: 15,
                        weight: FontWeight.w700),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Ionicons.checkmark_circle,
                          color: Colors.green, size: 20),
                      3.width,
                      Text(
                        "Sube una imagen clara y legible",
                        style: primaryTextStyle(
                            color: appStore.isDarkMode
                                ? scaffoldLightColor
                                : Colors.black87,
                            size: 14,
                            weight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Ionicons.checkmark_circle,
                          color: Colors.green, size: 20),
                      3.width,
                      Text(
                        "Todas las puntas deben ser visibles",
                        style: primaryTextStyle(
                            color: appStore.isDarkMode
                                ? scaffoldLightColor
                                : Colors.black87,
                            size: 14,
                            weight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Ionicons.checkmark_circle,
                          color: Colors.green, size: 20),
                      3.width,
                      Text(
                        "Maximo 2 MB",
                        style: primaryTextStyle(
                            color: appStore.isDarkMode
                                ? scaffoldLightColor
                                : Colors.black87,
                            size: 14,
                            weight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : const LoaderAppIcon();
  }

  Future<dynamic> _modalUploadDocument(
      BuildContext context, int frontalOrReverse) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "¿Cómo deseas subir el documento?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
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
                          onPressedRoute: () {
                            Navigator.pop(context); // cerrar alert
                            Navigator.pop(context); // Cerrar modal
                            _navigateToCameraScreen(
                                frontalOrReverse); // Tomar foto // Cierra el diálogo
                          },
                        );
                      });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: simon_finalPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                ),
                label: const Text("Tomar foto"),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomAlertDialog(
                          iconData: Icons.check_circle,
                          textButton: "Entendido",
                          withRedirection: false,
                          title: "Importante",
                          content:
                              "Para garantizar un proceso exitoso, los archivos subidos  deben ser de  calidad. Asegúrate de que sean nítidos y legibles, ya que imágenes borrosas o de baja resolución podrían afectar la validez de la impugnación",
                          onPressedRoute: () {
                            Navigator.pop(context); // cerrar alert
                            Navigator.pop(context); // Cerrar modal
                            if (frontalOrReverse == 1) {
                              _selectFileForField(
                                  "Cedula",
                                  ['jpg', 'jpeg', 'png', 'pdf'],
                                  frontalOrReverse);
                            } else {
                              _selectFileForField(
                                  "", ['jpg', 'jpeg', 'png'], frontalOrReverse);
                            }
                          },
                        );
                      });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: simon_finalPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.white,
                ),
                label: Text(frontalOrReverse == 2
                    ? "Seleccionar imagen de tu galeria"
                    : "Seleccionar documento de tu telefono"),
              ),
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: simonNaranja,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                    )),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Padding _buildImage(Size size, String direction, String? documentFilePath) {
    return Container(
      height: size.height * 0.25,
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: simon_finalSecondaryColor,
        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Mostrar nombre según condición
            if (documentFilePath != null)
              Text(
                "${widget.name} ($direction)",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

            documentFilePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(documentFilePath),
                      fit: BoxFit.cover,
                      height:
                          size.height * 0.20, // Ajuste de altura proporcional
                      width: size.width * 0.9,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        color: Colors.black,
                        size: 50,
                      ),
                    ),
                  ).paddingSymmetric(vertical: 3)
                : const Icon(
                    Icons.image_not_supported,
                    color: Colors.black,
                    size: 50,
                  ),
          ],
        ),
      ),
    ).paddingBottom(3);
  }
}
