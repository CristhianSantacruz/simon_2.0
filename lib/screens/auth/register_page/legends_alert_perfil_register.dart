import 'package:simon_final/main.dart';
import 'package:simon_final/providers/switch_provider.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';

class LegendsAlertPerfilRegister extends StatefulWidget {
  const LegendsAlertPerfilRegister({
    super.key,
  });

  @override
  State<LegendsAlertPerfilRegister> createState() =>
      _LegendsAlertPerfilRegisterState();
}

class _LegendsAlertPerfilRegisterState
    extends State<LegendsAlertPerfilRegister> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.privacy_tip,
              size: 80,
              color: simon_finalPrimaryColor,
            ),
            const SizedBox(height: 20),
             Text(
              "Autorización para el uso de datos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: appStore.isDarkMode ? Colors.white : Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
             Text(
              "Al continuar con la creación del perfil, la persona autoriza el uso de sus datos personales conforme a nuestras políticas de privacidad y términos de servicio.",
              style: TextStyle(fontSize: 14,color: appStore.isDarkMode ? Colors.white : Colors.black),
              textAlign: TextAlign.center,
             
            ),
            const SizedBox(height: 20),
            SizedBox(height: 150, child: Image.asset("assets/permiso.png")),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: context.watch<SwitchProvider>().isSwitchedOn,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    context.read<SwitchProvider>().toggleSwitch(value!);
                  },
                ),
                Flexible(
                  child: Text(
                    style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
                    "La persona autoriza el uso de sus datos personales para la creación del perfil.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            10.height,
          ],
        ),
      ),
    );
  }
}
