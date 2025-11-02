import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/movie_model.dart';
import '../widgets/comment_section.dart';
import '../services/api_service.dart';
import 'movie_detail_screen.dart';

class WatchScreen extends StatefulWidget {
  final Movie movie;

  const WatchScreen({super.key, required this.movie});

  @override
  State<WatchScreen> createState() => _WatchScreenState();
}

class _WatchScreenState extends State<WatchScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;

  bool isLoading = true;
  bool hasError = false;
  List<Movie> relatedMovies = [];

  @override
  void initState() {
    super.initState();
    _initVideo();
    _fetchRelatedMovies();
  }

  Future<void> _initVideo() async {
    try {
      final url = widget.movie.videoUrl;
      if (url == null || url.isEmpty) throw Exception("Không có video URL");

      // Nếu là YouTube ID hoặc URL YouTube
      if (_isYoutubeUrl(url) || _isYoutubeId(url)) {
        final videoId = _isYoutubeId(url) ? url : YoutubePlayer.convertUrlToId(url);
        if (videoId == null) throw Exception("YouTube ID không hợp lệ");

        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: true),
        );
      } else {
        // Phát link trực tiếp (.m3u8 hoặc .mp4)
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        await _videoController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoController!.value.aspectRatio,
        );
      }
    } catch (e) {
      debugPrint("⚠️ Lỗi khi khởi tạo video: $e");
      if (mounted) setState(() => hasError = true);
    }

    if (mounted) setState(() => isLoading = false);
  }

  bool _isYoutubeUrl(String url) =>
      url.contains("youtube.com") || url.contains("youtu.be");

  bool _isYoutubeId(String value) {
    final reg = RegExp(r'^[\w-]{11}$');
    return reg.hasMatch(value);
  }

  Future<void> _fetchRelatedMovies() async {
    try {
      final movies = await ApiService().getSimilarMovies(widget.movie.id);
      if (mounted) setState(() => relatedMovies = movies);
    } catch (e) {
      debugPrint("❌ Lỗi khi lấy phim liên quan: $e");
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  Widget _buildRelatedMovies() {
    if (relatedMovies.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🎞️ Phim tương tự",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedMovies.length,
            itemBuilder: (context, index) {
              final movie = relatedMovies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movie: movie),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          movie.posterPath != null && movie.posterPath!.isNotEmpty
                              ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
                              : 'https://via.placeholder.com/120x180.png?text=No+Image',
                          height: 140,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
                    child: hasError
                        ? const Center(
                            child: Icon(Icons.error_outline, color: Colors.white, size: 50),
                          )
                        : (_chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : (_youtubeController != null
                                ? YoutubePlayerBuilder(
                                    player: YoutubePlayer(
                                      controller: _youtubeController!,
                                      showVideoProgressIndicator: true,
                                    ),
                                    builder: (context, player) => player,
                                  )
                                : const Center(child: CircularProgressIndicator()))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.overview.isNotEmpty
                              ? movie.overview
                              : "Không có mô tả cho phim này.",
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        _buildRelatedMovies(),
                        const SizedBox(height: 20),
                        CommentSection(movieId: movie.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
