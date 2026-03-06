import 'package:flutter/material.dart';
import '../models/place.dart';
import '../screens/place_detail_screen.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onFavoriteToggle;

  const PlaceCard({super.key, required this.place, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(place: place),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần hình ảnh
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  place.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.image_not_supported_rounded, color: Colors.grey, size: 40),
                  ),
                ),
                // Nút tim ở góc ảnh
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      radius: 16,
                      child: Icon(
                        place.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Phần nội dung bên dưới
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  place.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      place.rating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
