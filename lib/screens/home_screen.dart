import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/api_service.dart';
import '../widgets/place_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Place>> _placesFuture;

  final List<String> _categories = ["Tất cả", "Biển đảo", "Núi rừng", "Di tích"];
  String _selectedCategory = "Tất cả";
  String _searchQuery = "";
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _placesFuture = _apiService.fetchPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TH3 - Vũ Văn Quảng - 2351160543', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded)),
        ],
      ),
      body: Column(
        children: [
          // Thanh lọc theo danh mục
          _buildCategoryChips(),
          // Thanh tìm kiếm
          _buildSearchBar(),
          // Danh sách địa danh
          Expanded(
            child: FutureBuilder<List<Place>>(
              future: _placesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu'));
                }

                // Lọc dữ liệu theo danh mục đã chọn và từ khóa tìm kiếm
                List<Place> places = snapshot.data!;
                
                // Lọc theo danh mục
                if (_selectedCategory != "Tất cả") {
                  places = places.where((p) => p.category == _selectedCategory).toList();
                }
                
                // Lọc theo từ khóa tìm kiếm
                if (_searchQuery.isNotEmpty) {
                  places = places
                      .where((p) =>
                          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          p.description.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                // Kiểm tra danh sách trống
                if (places.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Không tìm thấy địa danh nào'
                              : 'Không có dữ liệu',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                            child: const Text('Xóa tìm kiếm'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75, // Tỉ lệ chiều rộng/cao của thẻ
                  ),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return PlaceCard(
                      place: place,
                      onFavoriteToggle: () {
                        setState(() {
                          place.isFavorite = !place.isFavorite;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.blue.shade700,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              selectedColor: Colors.white,
              backgroundColor: Colors.blue.shade600,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm địa điểm...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = "");
                  },
                  child: const Icon(Icons.clear, color: Colors.grey),
                )
              : null,
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
