import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'login_screen.dart'; 

class IntroduceScreen extends StatefulWidget {
  const IntroduceScreen({super.key});

  @override
  State<IntroduceScreen> createState() => _IntroduceScreenState();
}

class _IntroduceScreenState extends State<IntroduceScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // ✅ DỮ LIỆU ĐÃ CẬP NHẬT: Thêm đường dẫn giả định cho hình nền
  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Phim, series không giới hạn và nhiều nội dung khác',
      'subtitle': 'Xem ở mọi nơi. Hủy bất kỳ lúc nào.',
      'image_path': 'assets/images/intro_bg_1.jpg', // Thay bằng đường dẫn ảnh thật của bạn
      'has_image': false,
    },
    {
      'title': 'Xem ở mọi nơi',
      'subtitle': 'Phát trực tuyến trên điện thoại, máy tính bảng, máy tính xách tay và TV của bạn.',
      'image_path': 'assets/images/intro_bg_2.jpg', // Thay bằng đường dẫn ảnh thật của bạn
      'has_image': true, // Giữ để hiển thị hình minh họa nhỏ
    },
    {
      'title': 'Ai cũng tìm được gói dịch vụ phù hợp',
      'subtitle': 'Gói dịch vụ có giá từ 74.000 đ.',
      'image_path': 'assets/images/intro_bg_3.jpg', // Thay bằng đường dẫn ảnh thật của bạn
      'has_image': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _controller.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Nền đen đậm khi không có ảnh load
      backgroundColor: const Color(0xFF0F1A2C), 
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'ONEPHIM',
          style: TextStyle(
            color: Colors.redAccent, // ✅ Màu đỏ nổi bật (giống Netflix)
            fontWeight: FontWeight.w900,
            fontSize: 28, // ✅ Tăng kích thước logo
          ),
        ),
        backgroundColor: Colors.transparent, // ✅ Nền trong suốt
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'QUYỀN RIÊNG TƯ',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          // ✅ Thay TextButton bằng ElevatedButton nhỏ cho ĐĂNG NHẬP
          ElevatedButton( 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, // ✅ Nút đỏ nổi bật
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('ĐĂNG NHẬP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // ✅ Cho phép nội dung hiển thị phía sau AppBar
      extendBodyBehindAppBar: true, 

      body: Stack(
        children: [
          // Trang cuộn
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return IntroSlide(data: _pages[index]);
            },
          ),

          // Chỉ báo và nút
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              // ✅ Thêm Gradient để chuyển từ nội dung slide sang nút BẮT ĐẦU
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1.0],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: const WormEffect(
                      dotColor: Colors.grey,
                      activeDotColor: Colors.redAccent, // ✅ Dùng màu đỏ
                      dotHeight: 8.0,
                      dotWidth: 8.0,
                      spacing: 8.0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent, // ✅ Nút BẮT ĐẦU đỏ đậm
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: const Text(
                        'BẮT ĐẦU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroSlide extends StatelessWidget {
  final Map<String, dynamic> data;

  const IntroSlide({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ HÌNH NỀN TOÀN MÀN HÌNH
        if (data['image_path'] != null)
          // LƯU Ý: Đảm bảo đã khai báo assets/images/ trong pubspec.yaml
          Image.asset(
            data['image_path'], 
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF0F1A2C),
              child: const Center(child: Icon(Icons.movie, color: Colors.white, size: 50)),
            ),
          ),
        
        // ✅ LỚP PHỦ ĐEN MỜ (GIÚP CHỮ NỔI BẬT)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // NỘI DUNG VĂN BẢN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Hình minh họa nhỏ
              if (data['has_image'] == true) ...[
                // Bạn có thể thay thế bằng một hình ảnh Asset thật
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "Hình minh họa",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
              
              Text(
                data['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32, // ✅ Kích thước lớn, mạnh mẽ
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                data['subtitle'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70, // ✅ Màu xám nhạt tinh tế
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}