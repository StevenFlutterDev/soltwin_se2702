import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soltwin_se2702/Dialogs/login_dialog.dart';
import 'package:soltwin_se2702/Providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //backgroundColor: Colors.indigo[900],
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
          letterSpacing: 1.2,
          color: Colors.white
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.lightbulb_outline,
            //color: Colors.white,
          ),
          onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
        ),
        TextButton(
          onPressed: (){
            context.go('/');
          },
          child: const Text(
            'Home',
            style: TextStyle(
                letterSpacing: 1.2,
            ),
          )
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TextButton(
              onPressed: (){
                showDialog(context: context, builder: (context){
                  return const LoginDialog();
                });
              },
              child: const Text(
                'Login',
                style: TextStyle(
                    letterSpacing: 1.2,
                ),
              )),
        )
      ],
    );
  }
}
