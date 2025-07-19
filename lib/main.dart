import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:wedband/ClientPage.dart';
import 'package:wedband/Configuration.dart';
import 'package:wedband/ServerPage.dart';

import 'Home.dart';

void main() {
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Configuration())
        ],
        child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
      title: 'Live Band',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
    ));
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => Home());
    case 'client':
      return MaterialPageRoute(builder: (_) => ClientPage(null));
    case 'server':
      return MaterialPageRoute(builder: (_) => ServerPage(null));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}
