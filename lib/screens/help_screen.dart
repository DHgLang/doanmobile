import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Trợ giúp', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          _buildHelpTile(Icons.question_answer, 'Câu hỏi thường gặp (FAQ)', () {}),
          _buildHelpTile(Icons.privacy_tip, 'Chính sách bảo mật', () {}),
          _buildHelpTile(Icons.email, 'Liên hệ hỗ trợ qua Email', () async {
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'support@onephim.com',
              queryParameters: {'subject': 'Yêu cầu hỗ trợ ứng dụng'},
            );
            if (await canLaunchUrl(emailLaunchUri)) {
              launchUrl(emailLaunchUri);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildHelpTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: onTap,
    );
  }
}