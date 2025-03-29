import 'package:flutter/material.dart';

class InfiniteMarquee extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double velocity;

  const InfiniteMarquee({
    Key? key,
    required this.text,
    this.style = const TextStyle(fontSize: 16, color: Colors.black),
    this.velocity = 50.0, // Velocidad del desplazamiento
  }) : super(key: key);

  @override
  _InfiniteMarqueeState createState() => _InfiniteMarqueeState();
}

class _InfiniteMarqueeState extends State<InfiniteMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Configura el AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Duración de la animación
    )..repeat(); // Repite la animación infinitamente

    // Configura la animación para mover el texto
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30, // Altura del mensaje
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_animation.value, 0),
            child: Text(
              widget.text,
              style: widget.style,
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          );
        },
      ),
    );
  }
}