class Spot {
  final String id;
  final String imageUrl;

  Spot({
    this.id,
    this.imageUrl,
  });

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'],
      imageUrl: json['imageUrl'],
    );
  }
}
