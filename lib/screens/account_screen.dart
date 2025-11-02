import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tài khoản', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildAccountTile(Icons.vpn_key, 'Gói dịch vụ', 'Cơ bản (74.000 đ/tháng)'),
          _buildAccountTile(Icons.credit_card, 'Thông tin thanh toán', 'Cập nhật thẻ Visa/Mastercard'),
          _buildAccountTile(Icons.security, 'Bảo mật', 'Quản lý các thiết bị đã đăng nhập'),
        ],
      ),
    );
  }

  Widget _buildAccountTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: () {
        // TODO: Điều hướng đến màn hình chi tiết tương ứng
      },
    );
  }
}