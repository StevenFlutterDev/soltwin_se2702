import 'package:flutter/material.dart';

class CustomComingSoonCard extends StatelessWidget {
  const CustomComingSoonCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return Card(
      elevation: 20,
      child: InkWell(
        onTap: () => {},
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Container(
          width: currentWidth / 5,
          height: currentHeight / 3,
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: -45 * (3.141592653589793 / 180),
            child: const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 30,
                //color: Colors.white24
              ),
            ),
          ),
        ),
      ),
    );
  }
}
