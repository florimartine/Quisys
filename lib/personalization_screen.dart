import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalizationScreen extends StatefulWidget {
  @override
  _PersonalizationScreenState createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  TextEditingController _roleController = TextEditingController();
  TextEditingController _hobbyController = TextEditingController();
  TextEditingController _competenceController = TextEditingController();
  List<String> _customRoles = [];
  List<String> _customHobbies = [];
  List<String> _customCompetence = [];

  @override
  void initState() {
    super.initState();
    _loadCustomizations();
  }

  // Charger les rôles et hobbies personnalisés depuis SharedPreferences
  Future<void> _loadCustomizations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customRoles = prefs.getStringList('custom_roles') ?? [];
      _customHobbies = prefs.getStringList('custom_hobbies') ?? [];
      _customCompetence = prefs.getStringList('custom_competence') ?? [];
    });
  }

  // Sauvegarder les rôles et hobbies personnalisés dans SharedPreferences
  Future<void> _saveCustomizations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_roles', _customRoles);
    await prefs.setStringList('custom_hobbies', _customHobbies);
    await prefs.setStringList('custom_competence', _customCompetence);
  }

  // Ajouter un rôle personnalisé
  void _addCustomRole() {
    if (_roleController.text.isNotEmpty) {
      setState(() {
        _customRoles.add(_roleController.text);
      });
      _roleController.clear();
      _saveCustomizations();
    }
  }

  // Ajouter un hobby personnalisé
  void _addCustomHobby() {
    if (_hobbyController.text.isNotEmpty) {
      setState(() {
        _customHobbies.add(_hobbyController.text);
      });
      _hobbyController.clear();
      _saveCustomizations();
    }
  }

  // Ajouter un compétence personnalisé
  void _addCustomCompetence() {
    if (_competenceController.text.isNotEmpty) {
      setState(() {
        _customCompetence.add(_competenceController.text);
      });
      _competenceController.clear();
      _saveCustomizations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personnalisation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ajout d'un rôle personnalisé
            TextField(
              controller: _roleController,
              decoration: InputDecoration(
                labelText: 'Ajouter un rôle personnalisé',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addCustomRole,
              child: Text('Ajouter un rôle'),
            ),
            SizedBox(height: 20),
            // Afficher les rôles personnalisés
            Text('Rôles personnalisés:'),
            Expanded(
              child: ListView.builder(
                itemCount: _customRoles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_customRoles[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _customRoles.removeAt(index);
                        });
                        _saveCustomizations();
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Ajout d'un hobby personnalisé
            TextField(
              controller: _hobbyController,
              decoration: InputDecoration(
                labelText: 'Ajouter un hobby personnalisé',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addCustomHobby,
              child: Text('Ajouter un hobby'),
            ),
            SizedBox(height: 20),
            // Afficher les hobbies personnalisés
            Text('Hobbies personnalisés:'),
            Expanded(
              child: ListView.builder(
                itemCount: _customHobbies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_customHobbies[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _customHobbies.removeAt(index);
                        });
                        _saveCustomizations();

                      },
                    ),
                  );
                },
              ),
            ),

            // Ajout d'un rôle personnalisé
            TextField(
              controller: _competenceController,
              decoration: InputDecoration(
                labelText: 'Ajouter une compétence personnalisé',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addCustomCompetence,
              child: Text('Ajouter une compétence'),
            ),
            SizedBox(height: 20),
            // Afficher les rôles personnalisés
            Text('Rôles personnalisés:'),
            Expanded(
              child: ListView.builder(
                itemCount: _customCompetence.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_customCompetence[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _customCompetence.removeAt(index);
                        });
                        _saveCustomizations();
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
