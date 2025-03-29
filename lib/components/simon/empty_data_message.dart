import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';

class EmptyDataMessage extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? textButton;
  final IconData? iconData;
  final void Function()? onPressed;
  const EmptyDataMessage({super.key, this.title, this.subtitle, this.onPressed,this.textButton,this.iconData});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        
        width: size.width * 0.8,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          color: simon_finalSecondaryColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal:12,vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.center,
               title ?? "Lo sentimos no hay datos",
              style: const TextStyle(color: Colors.black, fontSize: 15,fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Text(
              textAlign: TextAlign.center,
              subtitle ?? "Cualquier registro o error no dudes en consultarnos",
              style: const TextStyle(color: Colors.black, fontSize: 13,fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              icon: Icon(iconData ?? Icons.add,size: 30,color: Colors.white,),
              style: FilledButton.styleFrom(
                backgroundColor: simon_finalPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onPressed ?? () {},
              label: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  textButton ?? "Crear impugnacion",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
