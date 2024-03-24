import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.indigo[900],
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Image.asset(
          'assets/images/SOLLOGO.png',
          fit: BoxFit.fitWidth,
        ),
      ),
      leadingWidth: 160,
      title: const Text(
        'SOLTWIN',
        style: TextStyle(
          fontSize: 24,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: (){
            context.go('/');
          },
          child: const Text(
            'Home',
            style: TextStyle(
                letterSpacing: 1.2,
                color: Colors.white
            ),
          )
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TextButton(
              onPressed: (){},
              child: const Text(
                'Login',
                style: TextStyle(
                    letterSpacing: 1.2,
                    color: Colors.white
                ),
              )),
        )
      ],
    );
  }
}
