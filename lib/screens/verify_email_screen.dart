import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; 


class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isEmailSent = false;

  // 2. 🚨 THÊM HÀM ĐIỀU HƯỚNG DỨT KHOÁT 🚨
  void _goToLoginScreen() {
    // Điều hướng đến LoginScreen và xóa tất cả các màn hình khác trong stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false, 
    );
  }

  Future<void> _sendVerificationEmail() async {
    // ... (Giữ nguyên logic gửi email)
    try {
      final user = _auth.currentUser!;
      await user.sendEmailVerification();
      setState(() => _isEmailSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📧 Đã gửi email xác minh!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    await _auth.currentUser!.reload();
    final user = _auth.currentUser!;
    if (user.emailVerified) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Email đã được xác minh! Về trang đăng nhập.')),
        );
      }
      setState(() {}); // Cập nhật UI
      
      // 🚨 TỰ ĐỘNG CHUYỂN TRANG NẾU EMAIL ĐÃ XÁC MINH 🚨
      // Nếu bạn muốn tự động chuyển, hãy gọi hàm ở đây
      _goToLoginScreen();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Email chưa được xác minh.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _auth.currentUser?.email ?? "Người dùng";
    
    // Kiểm tra trạng thái đã xác minh để thay đổi giao diện/hành động
    
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác minh Email'),
        backgroundColor: Colors.blueAccent,
        // 🚨 GÁN HÀNH ĐỘNG NÚT QUAY LẠI VÀO HÀM ĐIỀU HƯỚNG DỨT KHOÁT 🚨
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          tooltip: 'Về trang Đăng nhập', 
          onPressed: _goToLoginScreen, // Gọi hàm điều hướng đến LoginScreen
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Xin chào, $userEmail', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text(
              'Vui lòng xác minh địa chỉ email của bạn để tiếp tục sử dụng ứng dụng.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            
            // Nút Gửi email
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              label: const Text('Gửi email xác minh'),
              onPressed: _isEmailSent ? null : _sendVerificationEmail,
            ),
            const SizedBox(height: 15),
            
            // Nút Kiểm tra trạng thái
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Kiểm tra trạng thái'),
              onPressed: _checkVerificationStatus,
            ),
            
            const SizedBox(height: 40),

            // Nút quay về trang Đăng nhập (tùy chọn)
            TextButton.icon(
              icon: const Icon(Icons.login, color: Colors.blueAccent),
              label: const Text('Về trang Đăng nhập'),
              onPressed: _goToLoginScreen,
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}