import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';

class MessagesToast {

  
  static showMessageSuccess(String message){
    toast(message,gravity: ToastGravity.TOP,textColor: Colors.white,bgColor: simon_finalPrimaryColor);
  }
  static showMessageError(String message){
    toast(message,gravity: ToastGravity.TOP,textColor: Colors.white,bgColor: simonNaranja);
  }
  static showMessageInfo(String message){ 
    toast(message,gravity: ToastGravity.TOP);
  }
  static showMessageSuccessWithContext(BuildContext context,String message){
    toasty(context,message,gravity: ToastGravity.TOP,textColor: Colors.white,bgColor: simon_finalPrimaryColor,borderRadius: BorderRadius.circular(DEFAULT_RADIUS),removeQueue: true);
  }
  static showMessageErrorWithContext(String message,BuildContext context){
    toasty(context,message,gravity: ToastGravity.TOP,textColor: Colors.white,bgColor: Colors.red,borderRadius: BorderRadius.circular(DEFAULT_RADIUS));
  }
  static showMessageInfoWithContext(String message,BuildContext context){
    toasty(context,message,gravity: ToastGravity.TOP,borderRadius: BorderRadius.circular(DEFAULT_RADIUS));
  }
}