import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soltwin_se2702/Providers/login_provider.dart';
import 'package:soltwin_se2702/Services/getset_preferences.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      elevation: 1.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      title: const Column(
        children: [
          Text('Logout Confirmation'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Logout')
                )
            );
            Provider.of<LoginProvider>(context, listen: false).setUserLogin(false); //Set login to false
            setRememberMe(false, '', ''); //Set (Remember me, Username, Password) to (False, null, null)
            setUserToken('Token'); //Remove User Token after logout.
            Navigator.pop(context);
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),
            backgroundColor: MaterialStateProperty.all<Color>(
              Colors.blue[900]!,
            ),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.white,
            ),
          ),

        ),

      ],

    );
  }
}
