import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:characters/characters.dart';

/// Service để tìm video trong Cloudinary theo tên phim.
class CloudinaryService {
  static const String cloudName = "dphkxkx20";
  static const String apiKey = "768268159977235";
  static const String apiSecret = "ag_5Wec6hMMbvUDxeu6J0LsUqqU";

  /// 🔧 Chuẩn hóa tên phim: bỏ dấu tiếng Việt, viết thường, thay khoảng trắng bằng "_"
  static String normalizeTitle(String input) {
    const vietnameseMap = {
      'a': 'áàảãạăắằẳẵặâấầẩẫậ',
      'A': 'ÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬ',
      'd': 'đ',
      'D': 'Đ',
      'e': 'éèẻẽẹêếềểễệ',
      'E': 'ÉÈẺẼẸÊẾỀỂỄỆ',
      'i': 'íìỉĩị',
      'I': 'ÍÌỈĨỊ',
      'o': 'óòỏõọôốồổỗộơớờởỡợ',
      'O': 'ÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ',
      'u': 'úùủũụưứừửữự',
      'U': 'ÚÙỦŨỤƯỨỪỬỮỰ',
      'y': 'ýỳỷỹỵ',
      'Y': 'ÝỲỶỸỴ',
    };

    vietnameseMap.forEach((nonAccent, accents) {
      for (var ch in accents.characters) {
        input = input.replaceAll(ch, nonAccent);
      }
    });

    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }

  /// 🔍 Tìm video theo tên phim trong Cloudinary (folder: /movies)
  static Future<String?> searchVideo(String movieTitle) async {
    const folder = "movies";
    final normalized = normalizeTitle(movieTitle);

    final searchQuery = "folder:$folder AND $normalized";
    final uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/resources/search");
    final authHeader =
        "Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}";

    print("🔎 [CloudinaryService] Đang tìm video...");
    print("🎬 Tên phim gốc: $movieTitle");
    print("🧩 Normalized: $normalized");
    print("📁 Query: $searchQuery");

    try {
      final response = await http.post(
        uri,
        headers: {
          "Authorization": authHeader,
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "expression": searchQuery,
          "max_results": 10,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resources = data["resources"] as List;

        if (resources.isNotEmpty) {
          final resource = resources.first;
          final publicId = resource["public_id"];
          final secureUrl = resource["secure_url"];
          print("✅ Tìm thấy video Cloudinary:");
          print("📦 Public ID: $publicId");
          print("🌐 URL gốc: $secureUrl");

          // 👉 Chuyển .mp4 sang .m3u8 (theo kiểu link bạn đang phát được)
          final hlsUrl = _toHlsUrl(secureUrl);
          print("🎬 Link HLS để phát: $hlsUrl");

          return hlsUrl;
        } else {
          print("❌ Không tìm thấy video cho '$movieTitle'");
        }
      } else {
        print("❌ Cloudinary API lỗi: ${response.statusCode}");
        print(response.body);
      }
    } catch (e) {
      print("⚠️ Lỗi khi kết nối Cloudinary: $e");
    }

    return null;
  }

  /// 🧠 Tạo link HLS hợp lệ (tránh dùng `sp_hd/f_m3u8`)
  static String _toHlsUrl(String url) {
    // Nếu đã có .m3u8 thì dùng luôn
    if (url.endsWith(".m3u8")) return url;

    // Nếu là .mp4 thì chỉ đổi phần mở rộng thành .m3u8
    if (url.endsWith(".mp4")) {
      return url.replaceAll(".mp4", ".m3u8");
    }

    // Nếu là định dạng khác (avi, mkv...) thì vẫn đổi đuôi
    return url.replaceAll(RegExp(r'\.\w+$'), '.m3u8');
  }
}
