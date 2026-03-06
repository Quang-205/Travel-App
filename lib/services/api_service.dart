import '../models/place.dart';

class ApiService {
  Future<List<Place>> fetchPlaces() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      // Danh sách địa danh với hình ảnh CHÍNH XÁC và ỔN ĐỊNH cho Web
      final List<Map<String, dynamic>> mockData = [
        {
          "id": "1",
          "name": "Vịnh Hạ Long",
          "image": "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&q=80&w=1000",
          "description": "Kỳ quan thiên nhiên thế giới với hàng nghìn hòn đảo đá vôi hùng vĩ.",
          "category": "Biển đảo",
          "rating": 4.9
        },
        {
          "id": "2",
          "name": "Phố Cổ Hội An",
          "image": "https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&q=80&w=400&h=500",
          "description": "Thành phố di sản với những dãy phố đèn lồng lung linh bên sông Hoài.",
          "category": "Di tích",
          "rating": 4.8
        },
        {
          "id": "3",
          "name": "Đảo Phú Quốc",
          "image": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=1000",
          "description": "Thiên đường nghỉ dưỡng với những bãi biển xanh ngắt và cát trắng mịn.",
          "category": "Biển đảo",
          "rating": 4.7
        },
        {
          "id": "4",
          "name": "Sapa",
          "image": "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&q=80&w=1000",
          "description": "Vẻ đẹp hùng vĩ của những thửa ruộng bậc thang giữa mây ngàn Tây Bắc.",
          "category": "Núi rừng",
          "rating": 4.8,
          "isFavorite": true
        }
      ];

      return mockData.map((item) => Place.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Lỗi kết nối mạng: Vui lòng kiểm tra lại đường truyền!');
    }
  }
}
