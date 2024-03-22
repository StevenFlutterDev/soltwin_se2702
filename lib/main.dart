import 'dart:html' as html;


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soltwin_se2702/Views/he104.dart';
import 'package:soltwin_se2702/Views/home.dart';
import 'package:soltwin_se2702/Views/se2702.dart';

void main() {
  runApp(MyApp());
  setupVisibilityChangeListener();
}

void setupVisibilityChangeListener() {
  html.document.addEventListener('visibilitychange', (_) {
    if (html.document.visibilityState == 'visible') {
      print('Page is visible');
      // Code to handle when the page becomes visible
    } else {
      print('Page is hidden');
      // Code to handle when the page becomes hidden
    }
  });
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
      GoRoute(
        path: '/se2702',
        builder: (BuildContext context, GoRouterState state){
          return const SE2702();
        }
      ),
      GoRoute(
        path: '/he104',
        builder: (BuildContext context, GoRouterState state){
          return const HE104();
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