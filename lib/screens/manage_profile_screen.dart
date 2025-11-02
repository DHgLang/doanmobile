import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageProfileScreen extends StatefulWidget {
  const ManageProfileScreen({super.key});

  @override
  State<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Lấy tên hiển thị hiện tại (nếu có)
    _displayNameController.text = _auth.currentUser?.displayName ?? '';
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Cập nhật tên hiển thị
        await user.updateDisplayName(_displayNameController.text.trim());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Cập nhật hồ sơ thành công!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi cập nhật: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Không cần dispose _displayNameController vì nó sẽ được dispose 
  // khi state bị hủy (thông qua super.dispose()), nhưng thêm vào cho đầy đủ.
  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Lấy email để hiển thị (không cho phép chỉnh sửa trực tiếp)
    final userEmail = _auth.currentUser?.email ?? 'Không có email';
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quản lý hồ sơ', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hiện email (không chỉnh sửa)
            Text(
              'Email: $userEmail',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const Divider(color: Colors.white10, height: 30),

            // Tên hiển thị
            TextField(
              controller: _displayNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
              ),
            ),
            const SizedBox(height: 30),

            // Nút cập nhật
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                : ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('CẬP NHẬT HỒ SƠ', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
            const SizedBox(height: 50),
            
            // Tùy chọn thay đổi mật khẩu
            TextButton(
              onPressed: () {
                // Triển khai logic gửi email đặt lại mật khẩu của Firebase
                if (_auth.currentUser?.email != null) {
                   _auth.sendPasswordResetEmail(email: _auth.currentUser!.email!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư.')),
                    );
                }
              },
              child: const Text(
                'Thay đổi Mật khẩu',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}