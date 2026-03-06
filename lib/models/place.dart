class Place {
  final String id;
  final String name;
  final String image;
  final String description;
  final String category; // Thêm: Danh mục (Biển đảo, Núi rừng,...)
  final double rating;   // Thêm: Đánh giá (4.5, 4.8,...)
  bool isFavorite;       // Giữ lại: Trạng thái yêu thích

  Place({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.category,
    required this.rating,
    this.isFavorite = false,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'].toString(),
      name: json['name'] ?? 'Không tên',
      image: json['image'] ?? 'https://via.placeholder.com/150',
      description: json['description'] ?? 'Không có mô tả',
      category: json['category'] ?? 'Khác',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
