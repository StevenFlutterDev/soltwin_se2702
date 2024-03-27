
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:soltwin_se2702/Providers/login_provider.dart';
import 'package:soltwin_se2702/Providers/theme_provider.dart';
import 'package:soltwin_se2702/Providers/water_level_provider.dart';
import 'package:soltwin_se2702/Views/he104.dart';
import 'package:soltwin_se2702/Views/home.dart';
import 'package:soltwin_se2702/Views/se2702.dart';

///Set Navigator globally
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: WaterLevelProvider()),
      ],
      child: ChangeNotifierProvider(
        create: (BuildContext context) => LoginProvider(),
        child: ChangeNotifierProvider(
          create: (BuildContext context) => ThemeProvider(),
          builder: (context, _){
            final themeProvider = Provider.of<ThemeProvider>(context);
            return MaterialApp.router(
              title: 'SOLTWIN SE270-2',
              theme: MyThemes.lightTheme,
              darkTheme: MyThemes.darkTheme,
              themeMode: themeProvider.themeData, // Force dark theme
              routerConfig: _routers,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}