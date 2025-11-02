import 'package:flutter/material.dart';
import 'movie_detail_screen.dart'; 
import '../models/movie_model.dart'; 
// Đảm bảo đường dẫn này đúng:
import '../services/favorites_service.dart'; 

class MyListScreen extends StatefulWidget {
  const MyListScreen({super.key});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  // ✅ KHÔNG CẦN Future/late Future
  final FavoritesService _favoritesService = FavoritesService(); 
  
  // Xóa hàm initState() vì chúng ta sẽ dùng StreamBuilder.
  // @override
  // void initState() {
  //   super.initState();
  //   _favoritesFuture = _favoritesService.fetchFavoriteMovies(); // Dòng này gây lỗi!
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Danh sách của tôi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ✅ THAY THẾ FutureBuilder BẰNG StreamBuilder
      body: StreamBuilder<List<Movie>>(
        stream: _favoritesService.getFavorites(), // ✅ GỌI HÀM ĐÚNG
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Hiển thị loading trong khi chờ kết nối (ban đầu)
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          } 
          if (snapshot.hasError) {
            // Xử lý lỗi
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } 
          
          final List<Movie> favoriteMovies = snapshot.data ?? [];

          if (favoriteMovies.isEmpty) {
            // Xử lý không có dữ liệu
            return const Center(
              child: Text('Bạn chưa thêm bộ phim nào vào danh sách.', style: TextStyle(color: Colors.white70)),
            );
          } 
          
          // Hiển thị dữ liệu
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: favoriteMovies.length,
            itemBuilder: (context, index) {
              final movie = favoriteMovies[index];
              return GestureDetector(
                 onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
                    );
                  },
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie.posterPath}', 
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(height: 120, color: Colors.grey[800], child: const Icon(Icons.movie, color: Colors.white54)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                );
            },
          );
        },
      ),
    );
  }
}