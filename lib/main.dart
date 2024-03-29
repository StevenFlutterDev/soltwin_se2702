
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/se2702',
          builder: (context, state) => const SE2702(),
          redirect: (context, state) async {
            // Ensure the provider is accessed within the context where it is available
            final loginProvider = Provider.of<LoginProvider>(context, listen: false);
            bool isAuthenticated = loginProvider.isLoggedIn;
            return isAuthenticated ? null : '/';
          },
        ),
        GoRoute(
          path: '/he104',
          builder: (context, state) => const HE104(),
        ),
      ],
    );

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
              routerConfig: router,
              //routerDelegate: router(context).routerDelegate,
              //routeInformationParser: router(context).routeInformationParser,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }

}