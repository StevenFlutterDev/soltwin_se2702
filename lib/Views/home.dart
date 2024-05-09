import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soltwin_se2702/CustomWidget/custom_app_bar.dart';
import 'package:soltwin_se2702/CustomWidget/custom_coming_soon_card.dart';
import 'package:soltwin_se2702/Dialogs/share_message_dialog.dart';
import 'package:soltwin_se2702/Providers/login_provider.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery
        .of(context)
        .size
        .width;
    final currentHeight = MediaQuery
        .of(context)
        .size
        .height;
    //bool isLoggedIn = Provider.of<LoginProvider>(context).isLoggedIn;
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 48.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    elevation: 20,
                    child: InkWell(
                      onTap: () {
                        if(true){
                          context.go('/se2702');
                        }else{
                          /*if(!mounted)return;
                          showDialog(
                              context: context,
                              builder: (context) => const ShareMessageDialog(
                                  contentMessage: 'Please login first before you can access any SOLTWIN Modelling.'
                              ));*/
                        }
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: SizedBox(
                        width: currentWidth / 5,
                        height: currentHeight / 3,
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset('assets/images/SE270-2.png'),
                              ),
                            ),
                            const Text(
                                'SE270-2', style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 8.0,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 20,
                    child: InkWell(
                      onTap: () {
                        if(true){
                          context.go('/he104');
                        }else{
                          /*if(!mounted)return;
                          showDialog(
                              context: context,
                              builder: (context) => const ShareMessageDialog(
                                  contentMessage: 'Please login first before you can access any SOLTWIN Modelling.'
                              ));*/
                        }
                      },
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: SizedBox(
                        width: currentWidth / 5,
                        height: currentHeight / 3,
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset('assets/images/HE104.png'),
                              ),
                            ),
                            const Text('HE104', style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 8.0,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const CustomComingSoonCard(),
                ],
              ),
              const SizedBox(height: 20,),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomComingSoonCard(),
                  CustomComingSoonCard(),
                  CustomComingSoonCard(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
