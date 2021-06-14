import 'package:flutter/material.dart';

import '../screens/home.dart';
import '../screens/notes_edit.dart';

class GenerateAllRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings, ) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => Home());
      case '/notes_edit':
        return MaterialPageRoute(builder: (context) => NotesEdit(settings.arguments));
      default:
        return _unknownRoute();
    }
  }
}

Route<dynamic> _unknownRoute() {
  return MaterialPageRoute(builder: (context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Oops!'),
      ),
      body: Center(
        child: Text('Page not found'),
      ),
    );
  });
}