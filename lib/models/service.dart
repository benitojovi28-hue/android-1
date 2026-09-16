class ServiceListing {
  const ServiceListing({
    required this.id,
    required this.titre,
    this.categorie,
    this.prix,
    this.prixUnite,
    this.devise,
    this.region,
    this.localisation,
    this.images = const [],
    this.isActive = true,
  });

  final String id;
  final String titre;
  final String? categorie;
  final num? prix;
  final String? prixUnite;
  final String? devise;
  final String? region;
  final String? localisation;
  final List<String> images;
  final bool isActive;

  factory ServiceListing.fromMap(Map<String, dynamic> map) {
    return ServiceListing(
      id: map['id'] as String,
      titre: map['titre'] as String? ?? '',
      categorie: map['categorie'] as String?,
      prix: map['prix'] as num?,
      prixUnite: map['prix_unite'] as String?,
      devise: map['devise'] as String?,
      region: map['region'] as String?,
      localisation: map['localisation'] as String?,
      images: (map['images'] as List?)?.cast<String>() ?? const [],
      isActive: map['is_active'] as bool? ?? true,
    );
  }
}
