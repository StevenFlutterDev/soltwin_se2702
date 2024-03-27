import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soltwin_se2702/Providers/water_level_provider.dart';

class WaterLevelAnimation extends StatelessWidget {
  final double height;
  final double width;
  final int tankNumber;

  const WaterLevelAnimation({
    Key? key,
    required this.height,
    required this.width,
    required this.tankNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterLevelProvider>(
      builder: (context, provider, child) {
        double level;
        switch (tankNumber) {
          case 1:
            level = provider.tank1Level;
            break;
          case 2:
            level = provider.tank2Level;
            break;
          case 3:
            level = provider.tank3Level;
            break;
          default:
            level = 0.0;
        }
        return CustomPaint(
          painter: WaterLevelPainter(level),
          child: SizedBox(
            width: width,
            height: height,
          ),
        );
      },
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
