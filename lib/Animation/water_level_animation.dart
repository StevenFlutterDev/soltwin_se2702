import 'package:flutter/material.dart';

class WaterLevelAnimation extends StatefulWidget {
  final double height;
  final double width;
  final bool shouldAnimate;
  final bool shouldReverse;
  const WaterLevelAnimation({super.key, required this.height, required this.width, required this.shouldAnimate, required this.shouldReverse});

  @override
  WaterLevelAnimationState createState() => WaterLevelAnimationState();
}

class WaterLevelAnimationState extends State<WaterLevelAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);

    controlAnimation();
  }

  void controlAnimation() {
    if (widget.shouldAnimate && !widget.shouldReverse) {
      _animationController!.forward();
    } else if (!widget.shouldAnimate && widget.shouldReverse) {
      _animationController!.reverse();
    } else {
      _animationController!.stop();
    }
  }

  @override
  void didUpdateWidget(covariant WaterLevelAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    controlAnimation();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WaterLevelPainter(_animation!.value),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
      ),
    );
  }
}

class WaterLevelPainter extends CustomPainter {
  final double level;

  WaterLevelPainter(this.level);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.blue;
    var path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * (1 - level));
    path.lineTo(size.width, size.height * (1 - level));
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
