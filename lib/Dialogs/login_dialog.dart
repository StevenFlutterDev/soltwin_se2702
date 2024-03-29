import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soltwin_se2702/Dialogs/forgot_password_dialog.dart';
import 'package:soltwin_se2702/Dialogs/share_message_dialog.dart';
import 'package:soltwin_se2702/Providers/login_provider.dart';
import 'package:soltwin_se2702/Services/getset_preferences.dart';
import 'package:soltwin_se2702/Services/rest_api.dart';

class LoginDialog extends StatefulWidget {

  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  bool _isLoading = false;
  final _username = TextEditingController();
  final _password = TextEditingController();
  final APIServices apiServices = APIServices();
  final formKey = GlobalKey<FormState>();
  bool keepMeLoggedIn = false;

  Future<bool> login(String username, String password)async{
    try{
      return await apiServices.loginReq(username, password);
    }
    catch(e){
      print(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 1.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LOGIN',
            style: TextStyle(
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8,),
          Text(
            'Enter your details to sign in to your account',
            style: TextStyle(
              letterSpacing: 1,
              fontSize: 12,
            ),
            textAlign: TextAlign.left,
          ),
          Divider(
            height: 10.0,
          )
        ],
      ),
      contentPadding: const EdgeInsets.all(24),
      content: _isLoading ? Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width/4,
          maxHeight: MediaQuery.of(context).size.height/4
        ),
        child: const Center(child: CircularProgressIndicator()),
      ) : Container(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width/4,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _username,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  contentPadding: EdgeInsets.only(top: 14.0),
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Username',
                ),
                onFieldSubmitted: (_) => submitForm(), // Trigger login on Enter press
              ),
              const SizedBox(height: 24,),
              TextFormField(
                controller: _password,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true, //hide text
                enableSuggestions: false, //disable auto suggest
                autocorrect: false, //disable autocorrect
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))
                  ),
                  contentPadding: EdgeInsets.only(top: 14.0),
                  prefixIcon: Icon(Icons.key),
                  labelText: 'Password',
                ),
                onFieldSubmitted: (_) => submitForm(), // Trigger login on Enter press
              ),
              const SizedBox(height: 24,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Checkbox(
                            value: keepMeLoggedIn,
                            checkColor: Colors.white,
                            activeColor: Colors.transparent,
                            onChanged: (value){
                              setState(() {
                                keepMeLoggedIn = value ?? false;
                                //Set Shared Preferences to store remember me state.

                                print(keepMeLoggedIn);
                              });
                            }
                        ),
                        const Text(
                          'Remember Me',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: (){
                          showDialog(context: context, builder: (context) => const ForgotPasswordDialog());
                        },
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.underline
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
                'Cancel'
            )
        ),
        ElevatedButton(
            onPressed: ()async {
              submitForm();
            },
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    )
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blue[900]!,
                )
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
              ),
            )
        ),
      ],

    );
  }

  void submitForm() async{
    setState(() {
      _isLoading = true;
    });
    if(await login(_username.text, _password.text)){
      if(keepMeLoggedIn){
        setRememberMe(true, _username.text, _password.text);
      }else{
        setRememberMe(false, '', '');
      }
      if(!mounted) return;
      Provider.of<LoginProvider>(context, listen: false).setUserLogin(true);
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Welcome Back, ${_username.text}')
          )
      );
      Navigator.pop(context);
    }else{
      if(!mounted) return;
      Provider.of<LoginProvider>(context, listen: false).setUserLogin(false);
      setState(() {
        _isLoading = false;
      });
      showDialog(context: context, builder: (context) => const ShareMessageDialog(contentMessage: 'Wrong Username or Password'));
    }
  }

}
