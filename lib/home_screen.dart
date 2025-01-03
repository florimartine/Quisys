import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';
import 'models/member.dart';
import 'member_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TextEditingController _tokenController = TextEditingController();
  TextEditingController _searchController = TextEditingController(); // Pour la recherche
  List<Member> _members = [];
  List<Member> _filteredMembers = []; // Liste filtrée pour la recherche
  String? _selectedRole;
  String? _selectedHobbies;
  String? _selectedComp;
  String? _selectedCouleur;


  late TabController _tabController;
  List<String> _customRoles = [];
  List<String> _customHobbies = [];
  List<String> _customCompetence = [];

  TextEditingController _roleController = TextEditingController();
  TextEditingController _hobbyController = TextEditingController();
  TextEditingController _competenceController = TextEditingController();

  bool _isTokenSectionVisible = false; // Ajouter une variable pour gérer la visibilité de la section du token

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 0; // Assurez-vous que l'index de l'onglet est à 0 au démarrage
    _tabController.addListener(_onTabChanged);
  _loadSavedMembers();
    _loadCustomizations(); // Charger les personnalisations
  }

  // Réinitialiser le questionnaire lors du changement d'onglet
  void _onTabChanged() {
    if (_tabController.index == 1) {
      setState(() {
        _selectedRole = null; // Réinitialiser la sélection du rôle
        _selectedHobbies = null; // Réinitialiser la sélection du hobby
        _selectedComp = null;
        _selectedCouleur = null;
      });
    }
  }

  // Charger les rôles et hobbies personnalisés depuis SharedPreferences
  Future<void> _loadCustomizations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customRoles = prefs.getStringList('custom_roles') ?? [];
      _customHobbies = prefs.getStringList('custom_hobbies') ?? [];
      _customCompetence = prefs.getStringList('custom_competence') ?? [];
      // Debugging: afficher les compétences personnalisées
      print('Competences personnalisées : $_customCompetence');
      _customRoles.sort();
      _customHobbies.sort();
      _customCompetence.sort();
    });
  }


  // Sauvegarder les rôles et hobbies personnalisés
  Future<void> _saveCustomizations() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('custom_roles', _customRoles);
    prefs.setStringList('custom_hobbies', _customHobbies);
    prefs.setStringList('custom_competence', _customCompetence);
  }

  // Ajouter un rôle personnalisé
  void _addCustomRole() {
    if (_roleController.text.isNotEmpty) {
      setState(() {
        _customRoles.add(_roleController.text);
        _customRoles.sort(); // Trier après l'ajout
        _roleController.clear();
      });
      _saveCustomizations();
    }
  }

  // Ajouter un hobby personnalisé
  void _addCustomHobby() {
    if (_hobbyController.text.isNotEmpty) {
      setState(() {
        _customHobbies.add(_hobbyController.text);
        _customHobbies.sort(); // Trier après l'ajout
        _hobbyController.clear();
      });
      _saveCustomizations();
    }
  }
  // Ajouter un rôle personnalisé
  void _addCustomCompetence() {
    if (_competenceController.text.isNotEmpty) {
      setState(() {
        _customCompetence.add(_competenceController.text);
        _customCompetence.sort(); // Trier après l'ajout
        _competenceController.clear();
      });
      _saveCustomizations();
    }
  }

  // Supprimer un rôle personnalisé et l'enlever des membres et du questionnaire
  void _removeCustomRole(String role) {
    if (_selectedRole == role) {
      setState(() {
        _selectedRole = null; // Supprimer le rôle sélectionné dans le questionnaire
      });
    }
    setState(() {
      _customRoles.remove(role);

      // Supprimer ce rôle de tous les membres
      for (var member in _members) {
        member.removeCustomInfo(role); // Supprimer le rôle des membres
      }
    });
    _saveCustomizations();
    _saveMembers();
  }

  // Supprimer un hobby personnalisé et l'enlever des membres et du questionnaire
  void _removeCustomHobby(String hobby) {
    if (_selectedHobbies == hobby) {
      setState(() {
        _selectedHobbies = null; // Supprimer le hobby sélectionné dans le questionnaire
      });
    }
    setState(() {
      _customHobbies.remove(hobby);

      // Supprimer ce hobby de tous les membres
      for (var member in _members) {
        member.removeCustomInfo(hobby); // Supprimer le hobby des membres
      }
    });
    _saveCustomizations();
    _saveMembers();
  }

  void _removeCustomCompetence(String competence) {
    if (_selectedComp == competence) {
      setState(() {
        _selectedComp = null; // Supprimer la competence sélectionné dans le questionnaire
      });
    }
    setState(() {
      _customCompetence.remove(competence);

      // Supprimer cette competence de tous les membres
      for (var member in _members) {
        member.removeCustomInfo(competence); // Supprimer la competence des membres
      }
    });
    _saveCustomizations();
    _saveMembers();
  }

  void _filterMembers(String query) {
    setState(() {
      // Si le champ de recherche est vide, on réinitialise la liste filtrée à la liste complète des membres
      if (query.isEmpty) {
        _filteredMembers = List.from(_members); // Copier la liste entière des membres
      } else {
        _filteredMembers = _members.where((member) {
          return member.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // Charger les membres sauvegardés depuis SharedPreferences
  Future<void> _loadSavedMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedMembers = prefs.getString('members');
    if (savedMembers != null) {
      List<dynamic> membersJson = json.decode(savedMembers);
      setState(() {
        _members = membersJson.map((memberData) => Member.fromJson(memberData)).toList();
        _members.sort((a, b) => a.name.compareTo(b.name)); // Trier par ordre alphabétique
      });
    }
  }

  // Sauvegarder les membres dans SharedPreferences
  Future<void> _saveMembers() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> membersJson = _members.map((member) => member.toJson()).toList();
    prefs.setString('members', json.encode(membersJson)); // Sauvegarde en JSON
  }

  // Fonction pour récupérer les membres via l'API et synchroniser avec ceux stockés
  Future<void> _getMembers() async {
    String token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() {
        _members = []; // Vider la liste si aucun token n'est fourni
      });
    } else {
      List<Member> membersFromApi = await fetchMembers(token);

      // Charger les membres sauvegardés depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? savedMembers = prefs.getString('members');
      List<Member> savedMembersList = [];

      if (savedMembers != null) {
        List<dynamic> savedMembersJson = json.decode(savedMembers);
        savedMembersList = savedMembersJson
            .map((memberData) => Member.fromJson(memberData))
            .toList();
      }

      // Synchroniser les membres sauvegardés avec ceux de l'API
      List<Member> membersToKeep = [];
      for (var apiMember in membersFromApi) {
        bool found = false;
        for (var savedMember in savedMembersList) {
          if (savedMember.name == apiMember.name) {
            // Fusionner les informations supplémentaires, conserver les données internes
            savedMember.additionalInfo = savedMember.additionalInfo ?? apiMember.additionalInfo;
            membersToKeep.add(savedMember);
            found = true;
            break;
          }
        }
        if (!found) {
          membersToKeep.add(apiMember); // Ajouter le membre de l'API s'il n'est pas trouvé
        }
      }



      // Supprimer les membres sauvegardés qui ne sont plus présents dans l'API
      savedMembersList.retainWhere((savedMember) =>
          membersToKeep.any((member) => member.name == savedMember.name));

      // Mettre à jour la liste des membres avec ceux à garder
      setState(() {
        _members = membersToKeep;
        _members.sort((a, b) => a.name.compareTo(b.name)); // Trier par ordre alphabétique
      });

      // Sauvegarder les membres synchronisés dans SharedPreferences
      _saveMembers();
    }
  }

  // Afficher le questionnaire avec les rôles et hobbies personnalisés
  Widget _buildQuestionnaire() {
    final Map<String, List<String>> infoOptions = {
      'Rôle': [..._customRoles, 'Protecteur', 'Social', 'Persecuteur', 'Hote','Little','Non-Humain']..sort(),
      'Hobbies': [..._customHobbies, 'Lecture', 'Jeux Vidéo', 'Sport', 'Voyages']..sort(),
      'Competence': [..._customCompetence, 'modifie l inner', 'souviens de tout', 'meilleur en dessin', 'chant']..sort(),
      'Couleur': ['rouge', 'bleu', 'jaune','vert','rose','orange','violet','gris','noir','blanc']..sort(),
    };

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélection du rôle
          DropdownButton<String>(
            hint: Text('Sélectionner un rôle'),
            value: infoOptions['Rôle']!.contains(_selectedRole)
                ? _selectedRole
                : null, // S'assurer que la valeur est valide
            onChanged: (newValue) {
              setState(() {
                _selectedRole = newValue;
              });
            },
            items: infoOptions['Rôle']!.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          // Sélection du hobby
          DropdownButton<String>(
            hint: Text('Sélectionner un hobby'),
            value: _selectedHobbies,
            onChanged: (newValue) {
              setState(() {
                _selectedHobbies = newValue;
              });
              if (newValue != null && !_customHobbies.contains(newValue)) {
                _customHobbies.add(newValue);
              }
            },
            items: infoOptions['Hobbies']!.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
          SizedBox(height: 20),
          DropdownButton<String>(
            hint: Text('Sélectionner une competence'),
            value: _selectedComp,
            onChanged: (newValue) {
              setState(() {
                _selectedComp = newValue;
              });
              if (newValue != null && !_customCompetence.contains(newValue)) {
                _customCompetence.add(newValue);
              }
            },
            items: infoOptions['Competence']!.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
          SizedBox(height: 20),
          DropdownButton<String>(
            hint: Text('Sélectionner une couleur'),
            value: _selectedCouleur,
            onChanged: (newValue) {
              setState(() {
                _selectedCouleur = newValue;
              });

            },
            items: infoOptions['Couleur']!.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
          ),
          SizedBox(height: 20),

          // Bouton pour réinitialiser les sélections
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedRole = null; // Réinitialiser le rôle
                _selectedHobbies = null; // Réinitialiser le hobby
                _selectedComp = null;
                _selectedCouleur = null;
              });
            },
            child: Text('Réinitialiser les sélections'),
          ),

          SizedBox(height: 20),
          // Afficher les membres correspondant aux critères
          if (_selectedRole != null || _selectedHobbies != null || _selectedComp !=null || _selectedCouleur !=null)...[
            Text('Membres correspondant aux critères :'),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: _members
                    .where((member) {
                  final matchesRole = _selectedRole == null ||
                      member.additionalInfo.contains('Rôle: $_selectedRole');
                  final matchesHobby = _selectedHobbies == null ||
                      member.additionalInfo.contains('Hobbies: $_selectedHobbies');
                  final matchesCompetence = _selectedComp == null ||
                      member.additionalInfo.contains('Competence: $_selectedComp');
                  final matchesCouleur = _selectedCouleur == null ||
                      member.additionalInfo.contains('Couleur: $_selectedCouleur');

                  return matchesRole && matchesHobby && matchesCompetence && matchesCouleur;
                })
                    .map((member) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: member.avatarUrl.isNotEmpty
                          ? CircleAvatar(backgroundImage: NetworkImage(member.avatarUrl))
                          : Icon(Icons.person),
                      title: Text(member.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemberDetailScreen(
                              member: member,
                              onSave: _saveMembers,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                })
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Rechercher un membre',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: _filterMembers, // Filtrer les membres à chaque changement
      ),
    );
  }

  // Afficher la liste des membres avec un bouton de suppression pour chaque membre
  Widget _buildMemberList() {
    if (_filteredMembers.isEmpty) {
      _filteredMembers = List.from(_members); // Initialisation de la liste filtrée à la liste complète des membres si vide
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSearchBar(), // Ajouter la barre de recherche
          SizedBox(height: 16),

          // Cette section est conditionnée par _isTokenSectionVisible
          Visibility(
            visible: _isTokenSectionVisible,
            child: Column(
              children: [
                TextField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    labelText: 'Entrez votre token Discord',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _getMembers,
                  child: Text('Obtenir les membres'),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: _filteredMembers.map((member) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: member.avatarUrl.isNotEmpty
                        ? CircleAvatar(backgroundImage: NetworkImage(member.avatarUrl))
                        : Icon(Icons.person),
                    title: Text(member.name),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _members.remove(member);
                          _filteredMembers.remove(member);
                        });
                        _saveMembers();
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MemberDetailScreen(
                            member: member,
                            onSave: _saveMembers,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quisys'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Membres'),
            Tab(text: 'Questionnaire'),
            Tab(text: 'Réponse personnalisée'),
          ],
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMemberList(),
          _buildQuestionnaire(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(  // Envelopper tout le contenu dans un SingleChildScrollView
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formulaire pour ajouter un rôle personnalisé
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
                  // Formulaire pour ajouter un hobby personnalisé
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
                  // Formulaire pour ajouter une compétence personnalisée
                  TextField(
                    controller: _competenceController,
                    decoration: InputDecoration(
                      labelText: 'Ajouter une compétence personnalisée',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addCustomCompetence,
                    child: Text('Ajouter une compétence'),
                  ),
                  SizedBox(height: 20),
                  // Liste des rôles personnalisés
                  Text('Rôles personnalisés :'),
                  SizedBox(height: 10),
                  Column(
                    children: _customRoles.map((role) {
                      return ListTile(
                        title: Text(role),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.purple),
                          onPressed: () => _removeCustomRole(role),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  // Liste des hobbies personnalisés
                  Text('Hobbies personnalisés :'),
                  SizedBox(height: 10),
                  Column(
                    children: _customHobbies.map((hobby) {
                      return ListTile(
                        title: Text(hobby),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.purple),
                          onPressed: () => _removeCustomHobby(hobby),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  // Liste des compétences personnalisées
                  Text('Compétences personnalisées :'),
                  SizedBox(height: 10),
                  Column(
                    children: _customCompetence.map((competence) {
                      return ListTile(
                        title: Text(competence),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.purple),
                          onPressed: () => _removeCustomCompetence(competence),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0 // Afficher le bouton flottant uniquement dans l'onglet "Membres"
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _isTokenSectionVisible = !_isTokenSectionVisible; // Toggle la visibilité
          });
        },
        child: Icon(_isTokenSectionVisible ? Icons.close : Icons.add),
      )
          : null, // Ne rien afficher dans les autres onglets_
    );
  }
}