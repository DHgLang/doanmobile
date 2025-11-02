import 'package:flutter/material.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  // Giả lập danh sách phim đã tải (bạn cần thay thế bằng dữ liệu thực)
  final List<Map<String, String>> downloadedItems = const [
    {'title': 'Phim Hành Động A', 'size': '500MB'},
    {'title': 'Series Phim B - Tập 1', 'size': '320MB'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tệp tải xuống', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: downloadedItems.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa tải xuống bất kỳ bộ phim nào.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: downloadedItems.length,
              itemBuilder: (context, index) {
                final item = downloadedItems[index];
                return ListTile(
                  leading: const Icon(Icons.movie, color: Colors.redAccent),
                  title: Text(item['title']!, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(item['size']!, style: const TextStyle(color: Colors.grey)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      // TODO: Triển khai logic xóa file đã tải
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã xóa ${item['title']}')),
                      );
                    },
                  ),
                  onTap: () {
                    // TODO: Mở WatchScreen để xem phim đã tải
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xem phim ${item['title']}')),
                    );
                  },
                );
              },
            ),
    );
  }
}