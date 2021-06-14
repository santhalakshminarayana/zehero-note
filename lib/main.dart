import 'package:flutter/material.dart';

import 'routes/route_generator.dart';

void main() async {
  runApp(new AppEntry());
}

class AppEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: GenerateAllRoutes.generateRoute,
    );
  }
}