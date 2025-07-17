class Features {
  final int bedRooms;
  final int bathRooms;
  final double areaInSquarFoot;
  final List<String> amenities;

  Features({
    required this.bedRooms,
    required this.bathRooms,
    required this.areaInSquarFoot,
    required this.amenities,
  });

  factory Features.fromJson(Map<String, dynamic> json) {
    try {
      return Features(
        bedRooms: json['bedRooms'] ?? 0,
        bathRooms: json['bathRooms'] ?? 0,
        areaInSquarFoot: (json['areaInSquarFoot'] ?? 0).toDouble(),
        amenities: List<String>.from(json['amenities'] ?? []),
      );
    } catch (e) {
      // Return default features if parsing fails
      return Features(
        bedRooms: 0,
        bathRooms: 0,
        areaInSquarFoot: 0.0,
        amenities: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'bedRooms': bedRooms,
      'bathRooms': bathRooms,
      'areaInSquarFoot': areaInSquarFoot,
      'amenities': amenities,
    };
  }
}
