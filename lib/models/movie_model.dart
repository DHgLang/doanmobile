class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double rating;
  final String releaseDate;
  final String? videoUrl; // 🔹 Dành cho phim thực (Firestore hoặc URL riêng)
  final List<String> genres; // 🔹 Thể loại phim

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
    required this.releaseDate,
    this.videoUrl,
    required this.genres,
  });

  /// 🔹 Parse từ TMDB API
  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> genreNames = [];

    // Nếu có danh sách genre object
    if (json['genres'] != null) {
      genreNames = List<Map<String, dynamic>>.from(
        json['genres'],
      ).map((g) => g['name'] as String).toList();
    }
    // Nếu chỉ có danh sách genre_id (thường trong các API list)
    else if (json['genre_ids'] != null) {
      genreNames = (json['genre_ids'] as List)
          .map((id) => _genreMap[id] ?? 'Unknown')
          .toList();
    }

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'No Title',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      rating: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? 'Unknown',
      videoUrl: null, // TMDB không có link video thật
      genres: genreNames,
    );
  }

  /// 🔹 Parse từ Firestore
  factory Movie.fromFirestore(Map<String, dynamic> data) {
    List<String> genreList = [];
    if (data['genres'] != null) {
      genreList = List<String>.from(data['genres']);
    }

    return Movie(
      id: data['id'] is int
          ? data['id']
          : int.tryParse(data['id'].toString()) ?? 0,
      title: data['title'] ?? 'No Title',
      overview: data['overview'] ?? '',
      posterPath: data['posterPath'] ?? '',
      backdropPath: data['backdropPath'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      releaseDate: data['releaseDate'] ?? 'Unknown',
      videoUrl: data['videoUrl'],
      genres: genreList,
    );
  }

  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? rating,
    String? releaseDate,
    String? videoUrl,
    List<String>? genres,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      rating: rating ?? this.rating,
      releaseDate: releaseDate ?? this.releaseDate,
      videoUrl: videoUrl ?? this.videoUrl,
      genres: genres ?? this.genres,
    );
  }

  /// 🔹 Chuyển sang Map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'rating': rating,
      'releaseDate': releaseDate,
      'videoUrl': videoUrl,
      'genres': genres,
    };
  }

  /// 🔹 URL ảnh TMDB
  String get posterUrl => "https://image.tmdb.org/t/p/w500$posterPath";
  String get backdropUrl => "https://image.tmdb.org/t/p/w780$backdropPath";

  /// 🔹 Dễ log thông tin
  @override
  String toString() {
    return 'Movie(id: $id, title: $title, rating: $rating, genres: $genres, videoUrl: $videoUrl)';
  }

  /// 🔹 Map thể loại từ TMDB ID → Tên
  static const Map<int, String> _genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };
}
