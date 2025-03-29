import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simon_final/components/simon/drow_component_register.dart';
import 'package:simon_final/components/simon/text_form_register.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';

class FirstPage extends StatefulWidget {
  final bool? isCreateProfile;
  static var controller = TextEditingController();
  static var formKey = GlobalKey<FormState>();
  static TextEditingController userNameController = TextEditingController();
  static TextEditingController lastNameController = TextEditingController();
  static TextEditingController birthdayController = TextEditingController();
  static TextEditingController maritalStatusController =
      TextEditingController();
  static TextEditingController genderController = TextEditingController();
  const FirstPage({super.key, this.isCreateProfile = false});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  void initState() {
    super.initState();
    // FirstPage.identificationTypeController.text = 'CEDULA';
  }

  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime maxDate = DateTime(now.year - 18, now.month, now.day);

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          // Para centrarlo en la pantalla
          child: Material(
            // Para manejar bordes y sombras
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Bordes redondeados
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // 90% del ancho de la pantalla
                height: 300,
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra superior con título y botón de cerrar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        color: simon_finalPrimaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Seleccionar Fecha",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // Picker de fecha
                    Expanded(
                      child: CupertinoDatePicker(
                        backgroundColor: Colors.white,
                        initialDateTime: maxDate,
                        minimumDate: DateTime(1900),
                        maximumDate: maxDate,
                        mode: CupertinoDatePickerMode.date,
                        dateOrder: DatePickerDateOrder.ymd,
                        use24hFormat: true,
                        onDateTimeChanged: (DateTime dateTime) {
                          setState(() {
                            _selectedDate = dateTime;
                            FirstPage.birthdayController.text =
                                DateFormat('yyyy-MM-dd').format(_selectedDate!);
                          });
                        },
                      ),
                    ),
                    Container(
                      
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16, bottom: 10),
                      child: TextButton(
                        onPressed: () {
                          if (_selectedDate != null) {
                            Navigator.pop(context);
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: simon_finalPrimaryColor,
                        ),
                        child: const Text(
                          "Aceptar",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 16),
            child: Row(
              children: [
                Text(
                  widget.isCreateProfile == true
                      ? 'Crear perfil'
                      : 'Datos personales',
                  style: primarytextStyle(size: 26),
                ),
                10.width,
                const Icon(
                  Ionicons.person_circle_outline,
                  color: simon_finalPrimaryColor,
                  size: 30,
                )
              ],
            ),
          ),
          firstForm(FirstPage.formKey)
        ],
      ),
    );
  }

  Form firstForm(GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormFieldRegister(
            textCapitalization: TextCapitalization.characters,
            controller: FirstPage.userNameController,
            label: 'Nombres Completos',
            icon: const Icon(
              Ionicons.people,
              color: simon_finalPrimaryColor,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nombre es requerido';
              }
              return null;
            },
          ),
          15.height,
          TextFormFieldRegister(
            textCapitalization: TextCapitalization.characters,
            controller: FirstPage.lastNameController,
            label: 'Apellidos Completos',
            icon: const Icon(Icons.family_restroom_outlined,
                color: simon_finalPrimaryColor),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Apellido es requerido";
              }
              return null;
            },
          ),
          15.height,
          buildBirthdayDate(context),
          15.height,
          DropdownTextFieldRegister(
            onChangedDropdown: (value) {
              setState(() {
                FirstPage.maritalStatusController.text = value!;
              });
            },
            hintText: "Estado Civil",
            controller: FirstPage.maritalStatusController,
            //icon: Icon(Icons.arrow_drop_down_outlined),
            items: const [
              DropdownMenuItem(
                value: "SOLTERO",
                child: Text('SOLTERO/A'),
              ),
              DropdownMenuItem(
                value: 'CASADO',
                child: Text('CASADO/A'),
              ),
              DropdownMenuItem(
                value: 'UNIONLIBRE',
                child: Text('UNIÓN LIBRE'),
              ),
              DropdownMenuItem(
                value: 'VIUDO',
                child: Text('VIUDO/A'),
              ),
              DropdownMenuItem(
                value: 'DIVORCIADO',
                child: Text('DIVORCIADO/A'),
              ),
            ],
          ),
          15.height,
          DropdownTextFieldRegister(
            onChangedDropdown: (value) {
              setState(() {
                FirstPage.genderController.text = value!;
              });
            },
            hintText: "Sexo",
            controller: FirstPage.genderController,
            items: const [
              DropdownMenuItem(value: "HOMBRE", child: Text('HOMBRE')),
              DropdownMenuItem(value: "MUJER", child: Text('MUJER')),
            ],
          ),
        ],
      ),
    );
  }

  GestureDetector buildBirthdayDate(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(),
      child: AbsorbPointer(
        child: TextFormField(
          style: TextStyle(
              color: appStore.isDarkMode ? Colors.white : Colors.black),
          validator: (value) => value!.isEmpty
              ? 'Por favor ingrese su fecha de nacimiento'
              : null,
          controller: FirstPage.birthdayController,
          decoration: inputDecoration(context,
              labelText: "Fecha de nacimiento",
              prefixIcon:
                  const Icon(Icons.cake, color: simon_finalPrimaryColor)),
        ),
      ),
    );
  }
}
