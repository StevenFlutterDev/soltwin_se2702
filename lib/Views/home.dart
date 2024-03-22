

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () => context.go('/se2702'),
                    child: Ink(
                      child: SizedBox(
                        width: currentWidth / 5,
                        height: currentHeight / 3,
                        child: Card(
                          //surfaceTintColor: Colors.white,
                          elevation: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Image.asset('assets/images/se270-2.png'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.go('/he104'),
                    child: Ink(
                      child: SizedBox(
                        width: currentWidth / 5,
                        height: currentHeight / 3,
                        child: Card(
                          //surfaceTintColor: Colors.white,
                          elevation: 20,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Image.asset('assets/images/HE104.png'),
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
