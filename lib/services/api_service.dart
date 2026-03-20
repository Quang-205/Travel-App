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
          "image": "https://picsum.photos/400/300?random=1",
          "description": "Kỳ quan thiên nhiên thế giới UNESCO với hàng nghìn hòn đảo đá vôi hùng vĩ giữa vịnh Bắc Bộ.",
          "category": "Biển đảo",
          "rating": 4.9
        },
        {
          "id": "2",
          "name": "Phố Cổ Hội An",
          "image": "https://picsum.photos/400/300?random=2",
          "description": "Di sản thế giới UNESCO với kiến trúc cổ kính, phố đèn lồng lung linh bên sông Hoài và ẩm thực đặc sắc.",
          "category": "Di tích",
          "rating": 4.8
        },
        {
          "id": "3",
          "name": "Đảo Phú Quốc",
          "image": "https://picsum.photos/400/300?random=3",
          "description": "Hòn ngọc Kiên Giang với bãi biển xanh ngắt, cát trắng mịn, rừng nguyên sinh và các khu nghỉ dưỡng sang trọng.",
          "category": "Biển đảo",
          "rating": 4.7
        },
        {
          "id": "4",
          "name": "Sapa",
          "image": "https://picsum.photos/400/300?random=4",
          "description": "Thành phố trong mây tây Bắc nổi tiếng với ruộng bậc thang, thiên nhiên hùng vĩ và lịch sự dân tộc thi少số.",
          "category": "Núi rừng",
          "rating": 4.8,
          "isFavorite": true
        },
        {
          "id": "5",
          "name": "Mausolée Hồ Chí Minh",
          "image": "https://picsum.photos/400/300?random=5",
          "description": "Lăng mộ trang trọng của Bác Hồ Chí Minh tại quảng trường Ba Đình, biểu tượng lịch sử và văn hóa Hà Nội.",
          "category": "Di tích",
          "rating": 4.6
        },
        {
          "id": "6",
          "name": "Chùa Một Cột",
          "image": "https://picsum.photos/400/300?random=6",
          "description": "Kiến trúc tôn giáo độc đáo Hà Nội với hình dáng tòa chùa nằm trên một trụ cột, biểu tượng nước Việt Nam.",
          "category": "Di tích",
          "rating": 4.5
        }
      ];

      return mockData.map((item) => Place.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Lỗi kết nối mạng: Vui lòng kiểm tra lại đường truyền!');
    }
  }
}
