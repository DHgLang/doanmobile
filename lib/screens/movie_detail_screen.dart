import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/movie_model.dart';
import '../widgets/comment_section.dart';
import '../screens/watch_screen.dart';
import '../services/api_service.dart';
import '../services/cloudinary_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final bool isFromFirestore;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    this.isFromFirestore = false,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isLoading = true;
  String? _trailerKey;

  @override
  void initState() {
    super.initState();
    _loadTrailer();
  }

  Future<void> _loadTrailer() async {
    if (widget.isFromFirestore || widget.movie.videoUrl != null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final api = ApiService();
      final key = await api.fetchMovieTrailer(widget.movie.id);
      setState(() {
        _trailerKey = key;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("⚠️ Lỗi tải trailer: $e");
      setState(() => _isLoading = false);
    }
  }

  void _openWatchScreen({required bool isTrailer}) async {
    String? videoUrl;
    bool fromFirestore = widget.isFromFirestore;

    if (isTrailer) {
      videoUrl = _trailerKey ?? widget.movie.videoUrl;
      fromFirestore = false;
    } else {
      videoUrl = widget.movie.videoUrl;
      if (videoUrl == null || videoUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("searching_cloudinary".tr())),
        );
        videoUrl = await CloudinaryService.searchVideo(widget.movie.title);
      }
    }

    if (videoUrl == null || videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("video_not_found".tr())),
      );
      return;
    }

    final movieToWatch = widget.movie.copyWith(videoUrl: videoUrl);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WatchScreen(movie: movieToWatch),
      ),
    );
  }

  Widget _buildPoster(double height) {
    final imageUrl = widget.movie.posterPath;
    if (imageUrl.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey[800],
        child: const Icon(Icons.broken_image, color: Colors.white30, size: 50),
      );
    }
    return Image.network(
      imageUrl.startsWith('http')
          ? imageUrl
          : 'https://image.tmdb.org/t/p/w500$imageUrl',
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: height,
        color: Colors.grey[800],
        child: const Icon(Icons.broken_image, color: Colors.white30, size: 50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(movie.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _buildPoster(400),
                      Container(
                        height: 400,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(
                              "watch_movie".tr(),
                              Icons.play_circle,
                              Colors.redAccent,
                              onPressed: () => _openWatchScreen(isTrailer: false),
                            ),
                            _buildButton(
                              "trailer".tr(),
                              Icons.movie_outlined,
                              Colors.white70,
                              onPressed: _trailerKey != null
                                  ? () => _openWatchScreen(isTrailer: true)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(movie.title,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          movie.overview.isNotEmpty
                              ? movie.overview
                              : "no_description".tr(),
                          style: const TextStyle(
                              color: Colors.white70, height: 1.5, fontSize: 15),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24),
                        CommentSection(movieId: movie.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildButton(String label, IconData icon, Color color,
      {VoidCallback? onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
