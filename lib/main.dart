import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soltwin_se2702/Views/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final GoRouter _routers = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state){
          return const HomePage();
        }
      ),
    ]
  );

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SOLTWIN SE270-2',
      theme: ThemeData.dark().copyWith(
        //primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _routers,
      debugShowCheckedModeBanner: false,
    );
  }
}