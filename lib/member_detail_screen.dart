import 'package:flutter/material.dart';
import 'models/member.dart'; // Importation du modèle Member
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Pour encoder/décoder en JSON

class MemberDetailScreen extends StatefulWidget {
  final Member member;
  final Future<void> Function() onSave; // Le paramètre de fonction pour sauvegarder

  MemberDetailScreen({required this.member, required this.onSave}); // Ajouter onSave

  @override
  _MemberDetailScreenState createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  List<String> _infoOptions = ['Rôle', 'Hobbies', 'Competence', 'Couleur'];
  Map<String, List<String>> _infoValues = {
    'Rôle': ['Protecteur', 'Social', 'Persecuteur', 'Hote','Little','Non-Humain'], // Valeurs par défaut
    'Hobbies': ['Lecture', 'Jeux Vidéo', 'Sport', 'Voyages'], // Valeurs par défaut
    'Competence': ['modifie l inner', 'souviens de tout', 'meilleur en dessin', 'chant'],
    'Couleur': ['rouge', 'bleu', 'jaune','vert','rose','orange','violet','gris','noir','blanc'],
  };

  String? _selectedInfo;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _loadCustomizations(); // Charger les personnalisations
  }

  // Charger les rôles et hobbies personnalisés depuis SharedPreferences
  Future<void> _loadCustomizations() async {
    final prefs = await SharedPreferences.getInstance();

    // Charger les rôles personnalisés et ajouter les valeurs par défaut s'ils sont vides
    List<String> customRoles = prefs.getStringList('custom_roles') ?? [];
    List<String> customHobbies = prefs.getStringList('custom_hobbies') ?? [];
    List<String> customCompetence = prefs.getStringList('custom_competence') ??[];

    // Combiner les rôles personnalisés avec les valeurs par défaut et trier ensemble
    if (customRoles.isNotEmpty) {
      _infoValues['Rôle'] = ['Protecteur', 'Social', 'Persecuteur', 'Hote','Little','Non-Humain'] + customRoles;
    }

    // Combiner les hobbies personnalisés avec les valeurs par défaut et trier ensemble
    if (customHobbies.isNotEmpty) {
      _infoValues['Hobbies'] = ['Lecture', 'Jeux Vidéo', 'Sport', 'Voyages'] + customHobbies;
    }

    if (customCompetence.isNotEmpty) {
      _infoValues['Competence'] = ['modifie l inner', 'souviens de tout', 'meilleur en dessin', 'chant'] + customCompetence;
    }
    // Trier les valeurs par ordre alphabétique
    _infoValues.forEach((key, values) {
      values.sort(); // Trier les valeurs par ordre alphabétique
    });

    // Mettre à jour l'interface utilisateur une fois les personnalisations chargées
    setState(() {});
  }

  // Fonction pour ajouter une information au membre
  void _addInformation() {
    if (_selectedInfo != null && _selectedValue != null) {
      widget.member.addInfo('${_selectedInfo!}: ${_selectedValue!}');
      setState(() {}); // Mettre à jour l'interface pour afficher les nouvelles informations

      // Sauvegarder les membres modifiés dans SharedPreferences
      widget.onSave(); // Appeler la fonction onSave pour sauvegarder
    }
  }

  // Fonction pour supprimer une information
  void _removeInformation(String info) {
    setState(() {
      widget.member.removeInfo(info);
    });

    // Sauvegarder les membres modifiés dans SharedPreferences
    widget.onSave(); // Appeler la fonction onSave pour sauvegarder
  }

  // Fonction pour sauvegarder les membres avec leurs informations supplémentaires dans SharedPreferences
  Future<void> _saveMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedMembers = prefs.getString('members');

    if (savedMembers != null) {
      List<dynamic> membersJson = json.decode(savedMembers);
      // Mettre à jour la liste des membres avec le membre actuel modifié
      for (int i = 0; i < membersJson.length; i++) {
        if (membersJson[i]['name'] == widget.member.name) {
          membersJson[i] = widget.member.toJson(); // Remplacer l'ancien membre avec le nouveau
          break;
        }
      }
      prefs.setString('members', json.encode(membersJson)); // Sauvegarder la nouvelle liste des membres
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage de l'avatar du membre
            CircleAvatar(
              radius: 100,
              backgroundImage: NetworkImage(widget.member.avatarUrl),
            ),
            SizedBox(height: 20),
            // Affichage du nom du membre
            Text(
              widget.member.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Formulaire pour sélectionner un type d'information
            DropdownButton<String>(
              value: _selectedInfo,
              hint: Text("Sélectionner une information"),
              onChanged: (newValue) {
                setState(() {
                  _selectedInfo = newValue;
                  _selectedValue = null; // Réinitialiser la valeur sélectionnée lorsque le type change
                });
              },
              items: _infoOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            // Affichage de la liste de valeurs disponibles pour l'information sélectionnée
            if (_selectedInfo != null)
              DropdownButton<String>( // Dropdown pour les valeurs standard
                value: _selectedValue,
                hint: Text("Sélectionner une valeur"),
                onChanged: (newValue) {
                  setState(() {
                    _selectedValue = newValue;
                  });
                },
                items: _infoValues[_selectedInfo!]!
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            SizedBox(height: 20),
            // Bouton pour ajouter une information
            ElevatedButton(
              onPressed: _addInformation,
              child: Text('Ajouter l\'information'),
            ),
            SizedBox(height: 20),
            // Affichage des informations supplémentaires
            Text(
              'Informations supplémentaires:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.member.additionalInfo.length,
                itemBuilder: (context, index) {
                  final info = widget.member.additionalInfo[index];
                  return ListTile(
                    title: Text(info),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeInformation(info); // Appeler la fonction pour supprimer l'information
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
