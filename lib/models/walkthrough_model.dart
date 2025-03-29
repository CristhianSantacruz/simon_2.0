import '../main.dart';
import '../utils/images.dart';

class WalkModel {
  String Function() imagePath;
  String title;
  String subtitle;

  WalkModel(this.imagePath, this.title, this.subtitle);
}

List<WalkModel> walkthroughList = [
  WalkModel(
    () => appStore.isDarkMode ? introduction_image_1 : introduction_image_1,
    'Impugna tus multas de manera rápida y eficaz',
    'Con Simón, realizar tus trámites de impugnación nunca fue tan fácil. Agiliza el proceso y obtén resultados sin complicaciones.'
  ),
  WalkModel(
    () => appStore.isDarkMode ? introduction_image_2 : introduction_image_2,
    'Gestiona y genera documentos legales fácilmente',
    'Accede a tus documentos desde cualquier lugar y genera automáticamente escritos en formatos legales listos para su presentación.'
  ),
  WalkModel(
    () => appStore.isDarkMode ? introduction_image_3 : introduction_image_3,
    'Firma rápidamente sin perder tiempo en el proceso',
    'Completa tus trámites de impugnación con una firma digital segura y válida, evitando largas esperas y procesos engorrosos.'
  ),
];
