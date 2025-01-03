import 'package:flutter/material.dart';
import 'home_screen.dart'; // Importer le fichier home_screen.dart
import 'personalization_screen.dart'; // Importer le fichier de personnalisation

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PluralKit API Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(), // Utiliser HomeScreen comme page d'accueil
      routes: {
        '/personalization': (context) => PersonalizationScreen(), // Ajouter la route pour la personnalisation
      },
    );
  }
}
