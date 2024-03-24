

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soltwin_se2702/CustomWidget/custom_app_bar.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context){
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
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
                      onTap: () => context.go('/se2702'),
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
                            const Text('SE270-2', style: TextStyle(fontSize: 20)),
                            const SizedBox(height: 8.0,)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 20,
                    child: InkWell(
                      onTap: () => context.go('/he104'),
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
                  Card(
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
                                color: Colors.white24
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
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
                              color: Colors.white24
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
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
                              color: Colors.white24
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
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
                              color: Colors.white24
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}
