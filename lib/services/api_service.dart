import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class ApiService {
  final String apiKey = 'e7a38b001b5bd78915172e6b5be5d148';
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String language = 'vi-VN';

  /// 🔹 Hàm tiện ích dùng để lấy danh sách phim từ API (có hỗ trợ nhiều trang)
  Future<List<Movie>> _fetchMovies(String endpoint, {int pages = 3}) async {
    List<Movie> allMovies = [];
    for (int page = 1; page <= pages; page++) {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint&page=$page'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['results'] as List)
            .map((e) => Movie.fromJson(e))
            .toList();
        allMovies.addAll(movies);
      } else {
        throw Exception('❌ Lỗi tải phim từ $endpoint (page $page)');
      }
    }
    return allMovies;
  }

  /// 🔥 Phim phổ biến
  Future<List<Movie>> fetchPopularMovies({int pages = 3}) async {
    return _fetchMovies(
      'movie/popular?api_key=$apiKey&language=$language',
      pages: pages,
    );
  }

  /// 🌍 Phim thịnh hành trong tuần
  Future<List<Movie>> fetchTrendingMovies({int pages = 2}) async {
    return _fetchMovies(
      'trending/movie/week?api_key=$apiKey&language=$language',
      pages: pages,
    );
  }

  /// 🏆 Phim được đánh giá cao
  Future<List<Movie>> fetchTopRatedMovies({int pages = 3}) async {
    return _fetchMovies(
      'movie/top_rated?api_key=$apiKey&language=$language',
      pages: pages,
    );
  }

  /// 🎬 Phim đang chiếu rạp
  Future<List<Movie>> fetchNowPlayingMovies({int pages = 2}) async {
    return _fetchMovies(
      'movie/now_playing?api_key=$apiKey&language=$language',
      pages: pages,
    );
  }

  /// ⏳ Phim sắp chiếu
  Future<List<Movie>> fetchUpcomingMovies({int pages = 2}) async {
    return _fetchMovies(
      'movie/upcoming?api_key=$apiKey&language=$language',
      pages: pages,
    );
  }

  /// 🎭 Phim theo thể loại (ví dụ: 28 = Action)
  Future<List<Movie>> fetchMoviesByGenre(int genreId, {int pages = 2}) async {
    return _fetchMovies(
      'discover/movie?api_key=$apiKey&language=$language&with_genres=$genreId',
      pages: pages,
    );
  }

  /// 🧠 Lấy danh sách thể loại
  Future<List<Map<String, dynamic>>> fetchGenres() async {
    final response = await http.get(
      Uri.parse('$baseUrl/genre/movie/list?api_key=$apiKey&language=$language'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['genres']);
    } else {
      throw Exception('Lỗi khi tải thể loại phim');
    }
  }

  /// 🔍 Tìm kiếm phim
  Future<List<Movie>> searchMovies(String query, {int pages = 2}) async {
    return _fetchMovies(
      'search/movie?api_key=$apiKey&language=$language&query=$query&include_adult=false',
      pages: pages,
    );
  }

  /// 🎥 Trailer (YouTube key)
  Future<String?> fetchMovieTrailer(int movieId) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/movie/$movieId/videos?api_key=$apiKey&language=en-US',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videos = data['results'] as List;
      final trailer = videos.firstWhere(
        (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
        orElse: () => null,
      );
      return trailer != null ? trailer['key'] : null;
    }
    return null;
  }

  /// 💫 Phim tương tự
  Future<List<Movie>> getSimilarMovies(int movieId, {int pages = 1}) async {
    return _fetchMovies(
      'movie/$movieId/similar?api_key=$apiKey&language=$language',
      pages: pages,
    );
  }

  /// 💡 Gợi ý phim: kết hợp popular + trending + top rated
  Future<List<Movie>> fetchRecommendedMovies({int limit = 20}) async {
    final popular = await fetchPopularMovies(pages: 1);
    final trending = await fetchTrendingMovies(pages: 1);
    final topRated = await fetchTopRatedMovies(pages: 1);
    final combined = [...popular, ...trending, ...topRated];
    combined.shuffle();
    return combined.take(limit).toList();
  }

  /// 🌈 Lấy phim ngẫu nhiên từ nhiều nguồn
  Future<List<Movie>> fetchAllCategoriesMovies() async {
    final popular = await fetchPopularMovies(pages: 2);
    final trending = await fetchTrendingMovies(pages: 2);
    final topRated = await fetchTopRatedMovies(pages: 2);
    final upcoming = await fetchUpcomingMovies(pages: 1);
    final nowPlaying = await fetchNowPlayingMovies(pages: 1);

    // ✅ Gộp tất cả & loại trùng
    final all = {
      ...popular,
      ...trending,
      ...topRated,
      ...upcoming,
      ...nowPlaying,
    }.toList();
    all.shuffle();
    return all;
  }
}
