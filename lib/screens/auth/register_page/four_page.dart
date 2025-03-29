import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';


class FourPage extends StatefulWidget {
  static TextEditingController passwordController = TextEditingController();
  static TextEditingController confirmPasswordController = TextEditingController();
  const FourPage({super.key});

  @override
  State<FourPage> createState() => _FourPageState();
}

class _FourPageState extends State<FourPage> {
  

  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;

  bool viewPassword = true;
  void checkPassword(String password) {
    setState(() {
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasLowercase = password.contains(RegExp(r'[a-z]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: const EdgeInsets.all(8),
    
      decoration: BoxDecoration(
       // color: Color(0xFF2C2C2E), // Fondo del card
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Padding(
            padding: const EdgeInsets.only(top: 8,left: 8,right: 8,bottom: 16),
            child: Text('La seguridad es nuestro deber 🔒',style: primarytextStyle(size: 26),),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: FourPage.passwordController,
            obscureText: viewPassword,
            onChanged: checkPassword,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock,color: simon_finalPrimaryColor,),
              suffixIcon:  IconButton(onPressed: (){
                setState(() {
                  viewPassword = !viewPassword;
                });
              }, icon: viewPassword ? const Icon(Icons.visibility,color: simon_finalPrimaryColor,) : const Icon(Icons.visibility_off,color: simon_finalPrimaryColor,),),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
              hintText: 'Contraseña', 
              hintStyle: const TextStyle(color:resendColor),
              filled: true,
              fillColor:Colors.white,
             
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: FourPage.confirmPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.black),
            
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock,color: simon_finalPrimaryColor,),
              
              hintText: 'Confirmar Contraseña',
              hintStyle: const TextStyle(color:resendColor),
               filled: true,
              fillColor:Colors.white,
               border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
             
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildValidationRow("Debe contener al menos una letra mayúscula", hasUppercase),
              _buildValidationRow("Debe tener al menos 8 caracteres", FourPage.passwordController.text.length >= 8),
              _buildValidationRow("Debe incluir al menos un número", hasNumber),
            ],
          ),
          const SizedBox(height: 24),
         /* SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (passwordController.text == confirmPasswordController.text &&
                    hasUppercase &&
                    hasLowercase &&
                    hasNumber) {
                  // Acción si todo está correcto
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Password valid and matched!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Check password conditions.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9C27B0), // Color botón
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'CONTINUE',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildValidationRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isValid ? Colors.green : resendColor,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style:primarytextStyle(size: 14,weight: FontWeight.w400),
        ),
      ],
    );
  }

}