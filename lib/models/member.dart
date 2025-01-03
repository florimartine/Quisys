class Member {
  final String name;
  final String avatarUrl;
  List<String> additionalInfo; // Liste des informations supplémentaires

  Member({
    required this.name,
    required this.avatarUrl,
    this.additionalInfo = const [], // Liste vide par défaut
  });

  // Méthode pour créer un objet Member à partir d'un Map
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['name'] ?? 'Nom non disponible',
      avatarUrl: json['avatar_url'] ?? '',
      additionalInfo: List<String>.from(json['additional_info'] ?? []), // On récupère la liste d'infos supplémentaires si présente
    );
  }

  // Méthode pour convertir un objet Member en Map (pour la persistance en JSON)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar_url': avatarUrl,
      'additional_info': additionalInfo,
    };
  }

  // Méthode pour ajouter une information à la liste
  void addInfo(String info) {
    additionalInfo.add(info);
  }

  // Méthode pour supprimer une information de la liste
  void removeInfo(String info) {
    additionalInfo.remove(info);
  }

  // Méthode pour supprimer une information spécifique à un rôle ou un hobby personnalisé
  void removeCustomInfo(String customInfo) {
    additionalInfo.removeWhere((info) => info.contains(customInfo));
  }
}
