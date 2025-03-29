import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';

class CameraScreen extends StatefulWidget {
  final String nameDocument;
  final bool largeDocument;
  final String? textButtonPhoto;

  const CameraScreen(
      {super.key, required this.nameDocument, this.largeDocument = false,this.textButtonPhoto});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraFuture;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCameraFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.high);
    await _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeCameraFuture;
      final image = await _cameraController.takePicture();

      // Recortar la imagen capturada
      final croppedFile = widget.largeDocument
        ? await cropLargeDocument(image.path) 
        : await cropImageCenter(image.path); 

      setState(() {
        _capturedImagePath = croppedFile.path;
      });
    } catch (e) {
      print("Error al tomar la foto: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al tomar la foto. Inténtalo de nuevo.")),
      );
    }
  }

  Future<File> cropLargeDocument(String imagePath) async {
    final originalFile = File(imagePath);
    final bytes = await originalFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception("No se pudo decodificar la imagen");
    }

    // Dimensiones del contenedor para documentos grandes
    final containerWidth = 350;
    final containerHeight = 600;

    // Calcular la relación de aspecto de la imagen original
    final originalAspectRatio = originalImage.width / originalImage.height;
    final containerAspectRatio = containerWidth / containerHeight;

    // Ajustar el recorte para que coincida con el contenedor
    int cropWidth, cropHeight;
    if (originalAspectRatio > containerAspectRatio) {
      // La imagen es más ancha que el contenedor
      cropHeight = originalImage.height;
      cropWidth = (cropHeight * containerAspectRatio).toInt();
    } else {
      // La imagen es más alta que el contenedor
      cropWidth = originalImage.width;
      cropHeight = (cropWidth / containerAspectRatio).toInt();
    }

    // Calcular las coordenadas de recorte (centrado)
    final cropX = (originalImage.width - cropWidth) ~/ 2;
    final cropY = (originalImage.height - cropHeight) ~/ 2;

    // Recortar la imagen
    final croppedImage = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    // Redimensionar la imagen recortada al tamaño del contenedor (350x600)
    final resizedImage = img.copyResize(
      croppedImage,
      width: containerWidth,
      height: containerHeight,
    );

    // Guardar la imagen recortada y redimensionada
    final newPath = '${imagePath}_cropped_large.jpg';
    final croppedFile =
        await File(newPath).writeAsBytes(img.encodeJpg(resizedImage));

    return croppedFile;
  }

  // Método para recortar
  Future<File> cropImageCenter(String imagePath) async {
    final originalFile = File(imagePath);
    final bytes = await originalFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    if (originalImage == null)
      throw Exception("No se pudo decodificar la imagen");

    // Ejemplo de recorte centrado, ajustar según tu recuadro
    final centerX = originalImage.width ~/ 2;
    final centerY = originalImage.height ~/ 2;
    final cropWidth = 600;
    final cropHeight = 400;
    final cropX = centerX - cropWidth ~/ 2;
    final cropY = centerY - cropHeight ~/ 2;

    final croppedImage = img.copyCrop(originalImage,
        x: cropX, y: cropY, width: cropWidth, height: cropHeight);
    final newPath = '${imagePath}_cropped.jpg';
    final croppedFile =
        await File(newPath).writeAsBytes(img.encodeJpg(croppedImage));

    return croppedFile;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: FutureBuilder<void>(
      future: _initializeCameraFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              Positioned.fill(child: CameraPreview(_cameraController)),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.7),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                    Center(
                      child: Container(
                        width: widget.largeDocument ? 350 : 300,
                        height: widget.largeDocument ? 600 : 200,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Esquinas del recuadro
              buildContainer(context, widget.largeDocument),
              Positioned(
                top: 50, // Distancia desde el borde superior
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.black
                          .withOpacity(0.5), // Fondo semitransparente
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      "Coloca el documento dentro del recuadro",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: AppButton(
                    elevation: 2,
                    color: simon_finalPrimaryColor,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                        ),
                        10.width,
                        Text(
                          widget.textButtonPhoto ?? "Tomar Foto",
                          style: primarytextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    onTap: () {
                      _takePhoto();
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context, _capturedImagePath);
                      });
                    },
                  ))
            ],
          );
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error al inicializar la cámara.'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ));
  }
}

Widget buildContainer(BuildContext context, bool largeDocument) {
  double containerWidth = largeDocument ? 350 : 300;
  double containerHeight = largeDocument ? 600 : 200;

  return Center(
    child: Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 2),
      ),
      child: CustomPaint(
        size: Size(containerWidth, containerHeight),
        painter: BorderCornerPainter(
          color: simonVerde,
          strokeWidth: 4,
        ),
      ),
    ),
  );
}

class BorderCornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  BorderCornerPainter({required this.color, this.strokeWidth = 4});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final cornerSize = 20.0;

    // Esquinas superiores
    canvas.drawLine(const Offset(0, 0), Offset(cornerSize, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, cornerSize), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width - cornerSize, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerSize), paint);

    // Esquinas inferiores
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - cornerSize), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(cornerSize, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - cornerSize), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - cornerSize, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
