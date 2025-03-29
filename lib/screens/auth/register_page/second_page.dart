import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simon_final/components/simon/drow_component_register.dart';
import 'package:simon_final/components/simon/text_form_register.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/profession_model.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/professions_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:ionicons/ionicons.dart';

class SecondPage extends StatefulWidget {
  static var formKey = GlobalKey<FormState>();
  static TextEditingController maritalStatusController =TextEditingController();
  static TextEditingController professionController = TextEditingController();
    static  TextEditingController identificationTypeController =TextEditingController();
  static TextEditingController  identificationController =TextEditingController();
  static TextEditingController  nombramientoController =TextEditingController();
  static var phoneController = TextEditingController();
  final bool? isCreateProfile;
  const SecondPage({super.key,this.isCreateProfile = false});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<ProfessionModel> _professions = [];
  final _professionServices = ProfessionServices();
  @override
  void initState() {
    super.initState();
     SecondPage.identificationTypeController.text = 'CEDULA';
     SecondPage.maritalStatusController.text.isNotEmpty
        ? SecondPage.maritalStatusController.text
        : null;
    _loadProfessions();
  }


  void _loadProfessions() async {
    final professions = await _professionServices.getProfessions();
    setState(() {
      _professions = professions;
    });
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
            child: Text(
              widget.isCreateProfile == true ? 'Mas sobre el nuevo perfil' : 'Mas Sobre ti',
              style: primarytextStyle(size: 26),
            ),
          ),
          secondForm(context, SecondPage.formKey),
        ],
      ),
    );
  }

  Form secondForm(BuildContext context, GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Column(
        children: [
         /* DropdownTextFieldRegister(
            onChangedDropdown: (value) {
              setState(() {
                SecondPage.maritalStatusController.text = value!;
              });
            },
            hintText: "Estado Civil",
            controller: SecondPage.maritalStatusController,
            //icon: Icon(Icons.arrow_drop_down_outlined),
            items: [
              DropdownMenuItem(
                value: "SOLTERO",
                child: Text('Soltero'),
              ),
              DropdownMenuItem(
                value: 'CASADO',
                child: Text('Casado'),
              ),
            ],
          ),*/
          DropdownButtonFormField<String>(
             dropdownColor: appStore.isDarkMode ?scaffoldSecondaryDark : Colors.white, 
            style: TextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black,fontSize: 16),
            value: SecondPage.professionController.text.isNotEmpty
                ? SecondPage.professionController.text
                : null,
            onChanged: (String? value) {
              setState(() {
                SecondPage.professionController.text = value!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Seleccione una profesión';
              }
              return null;
            },
            decoration: InputDecoration(
               fillColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
              labelText: 'Profesión',
              prefixIcon: const Icon(
                Icons.work_outlined,
                color: simon_finalPrimaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            items: _professions
                .map((profession) => DropdownMenuItem<String>(
                      value: profession.id.toString(),
                      child: Text(profession.name),
                    ))
                .toList(),
          ),
          15.height,
          DropdownTextFieldRegister(
            value: SecondPage.identificationTypeController.text,
            onChangedDropdown: (value) {
             setState(() {
               SecondPage.identificationTypeController.text = value!;
             });
            },
            hintText: "Tipo de identificación",
            controller: SecondPage.identificationTypeController,
            icon: const Icon(FontAwesomeIcons.idCardClip,color: simon_finalPrimaryColor),
            items: const [
              DropdownMenuItem(
                value: 'CEDULA',
                child: Text('Cédula'),
              ),
               DropdownMenuItem(
                value: 'RUC',
                child: Text('Ruc'),
              ),         
            ],
          ),
          15.height,
          TextFormFieldRegister(
            //maxLength: SecondPage.identificationTypeController.text == 'CEDULA' ? 10 : 13,
            //showMaxLength: true,
            keyboardType: TextInputType.number,
            icon: const Icon(Ionicons.finger_print,color: simon_finalPrimaryColor),
              label: "Identificación",
              controller: SecondPage.identificationController,
              inputFormatters: [
                if(SecondPage.identificationTypeController.text == 'CEDULA')  LengthLimitingTextInputFormatter(10),
                if(SecondPage.identificationTypeController.text == 'RUC') LengthLimitingTextInputFormatter(13),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Identificación es requerida';
                }
                if(SecondPage.identificationTypeController.text == 'CEDULA'){
                  if(value.length != 10){
                    return 'Cédula debe tener 10 dígitos';
                  }
                } else {
                  if(value.length != 13){
                    return 'RUC debe tener 13 dígitos';
                  }
                }          
                return null;
              }),
           15.height,  
           SecondPage.identificationTypeController.text == 'RUC' ? TextFormFieldRegister(
            controller: SecondPage.nombramientoController,
            label: "Nombramiento",
            keyboardType: TextInputType.text,
            inputFormatters: const [
              //FilteringTextInputFormatter.digitsOnly,
              //LengthLimitingTextInputFormatter(13),
            ],
            validator: (value) {
             
             return null;
            },
          ).paddingBottom(15) : const SizedBox(),
          
        //  buildBirthdayDate(context),
          TextFormFieldRegister(
           // maxLength: 10,
           // showMaxLength: true,
              controller: SecondPage.phoneController,
              label: 'Teléfono',
              icon: const Icon(
                Icons.phone,
                color: 
                     simon_finalPrimaryColor,
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Teléfono es requerido';
                }
                if (value.length != 10) {
                  return 'Teléfono debe tener 10 dígitos';
                }
                return null;
              },
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly,
              ]),
        ],
      ),
    );
  }

 /* GestureDetector buildBirthdayDate(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          style: TextStyle(
              color: appStore.isDarkMode ? Colors.white : Colors.black),
          validator: (value) => value!.isEmpty
              ? 'Por favor ingrese su fecha de nacimiento'
              : null,
          controller: SecondPage.birthdayController,
          decoration: inputDecoration(context,
              labelText: "Fecha de nacimiento",
              prefixIcon: Icon(Icons.cake,
                  color: appStore.isDarkMode
                      ? Colors.white
                      : simon_finalPrimaryColor)),
        ),
      ),
    );
  }*/
}
