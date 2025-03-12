class Complex {
  final String documentId;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;

  Complex({
    required this.documentId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
  });
}
