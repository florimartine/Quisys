import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/member.dart';  // Assure-toi d'importer le fichier member.dart

// Fonction pour récupérer la liste des membres à partir de l'API
Future<List<Member>> fetchMembers(String token) async {
  const String apiUrl = 'https://api.pluralkit.me/v2/systems/@me/members';

  try {
    // Envoi de la requête GET avec le header Authorization
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': token, // Utilise le token passé en paramètre
      },
    );

    if (response.statusCode == 200) {
      // Décoder les données JSON
      final data = json.decode(response.body);

      // Mapper la réponse à une liste de membres
      List<Member> members = [];
      for (var memberData in data) {
        members.add(Member.fromJson(memberData)); // Crée chaque membre
      }

      // Retourner la liste des membres
      return members;
    } else {
      // Gérer les erreurs de réponse
      print('Erreur lors de la requête : ${response.statusCode}');
      return [];
    }
  } catch (e) {
    // Gérer les exceptions
    print('Erreur lors de la requête API : $e');
    return [];
  }
}
