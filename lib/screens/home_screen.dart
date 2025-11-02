import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/api_service.dart';
import '../models/movie_model.dart';
import 'movie_detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();

  List<Movie> currentMovies = [];
  String selectedCategoryKey = 'recommended'; // Lưu key, không lưu label
  bool isLoading = true;

  final List<String> categoryKeys = [
    'recommended',
    'recent',
    'single',
    'series',
  ];

  @override
  void initState() {
    super.initState();
    loadCategory(selectedCategoryKey);
  }

  Future<void> loadCategory(String key) async {
    setState(() {
      selectedCategoryKey = key;
      isLoading = true;
      currentMovies = [];
    });

    try {
      List<Movie> movies = [];
      switch (key) {
        case 'recommended':
          movies = await apiService.fetchRecommendedMovies(limit: 12);
          break;
        case 'recent':
          movies = await apiService.fetchUpcomingMovies(pages: 1);
          break;
        case 'single':
          movies = await apiService.fetchMoviesByGenre(28);
          break;
        case 'series':
          movies = await apiService.fetchMoviesByGenre(18);
          break;
      }
      setState(() {
        currentMovies = movies;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ✅ Category selector với màu xanh Onephim
  Widget buildCategorySelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categoryKeys.length,
        itemBuilder: (context, index) {
          final key = categoryKeys[index];
          final isSelected = key == selectedCategoryKey;
          return GestureDetector(
            onTap: () => loadCategory(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E90FF) : Colors.grey[850],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  key.tr(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[300],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildMovieGrid() {
    if (isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF1E90FF)),
        ),
      );
    }

    if (currentMovies.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Text(
            'no_movies'.tr(),
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        int crossAxisCount;
        if (screenWidth < 600) {
          crossAxisCount = 3;
        } else if (screenWidth < 900) {
          crossAxisCount = 4;
        } else {
          crossAxisCount = 5;
        }

        const double aspectRatio = 0.6;
        double dynamicFontSize =
            (screenWidth / crossAxisCount) * 0.12 < 13 ? 13 : (screenWidth / crossAxisCount) * 0.12;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currentMovies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            final movie = currentMovies[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailScreen(movie: movie),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black87],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: dynamicFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildRecommendedCarousel() {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<List<Movie>>(
      future: apiService.fetchRecommendedMovies(limit: 8),
      builder: (context, snapshot) {
        final double carouselHeight = screenWidth * 0.55;
        final double viewportFraction = screenWidth > 600 ? 0.6 : 0.8;

        if (!snapshot.hasData) {
          return SizedBox(
            height: carouselHeight,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E90FF)),
            ),
          );
        }

        final movies = snapshot.data!;

        return SizedBox(
          height: carouselHeight,
          child: PageView.builder(
            controller: PageController(viewportFraction: viewportFraction),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movie: movie),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie.backdropPath}',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Colors.transparent, Colors.black54],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'ONEPHIM',
          style: TextStyle(
            color: Color(0xFF1E90FF), // ✅ xanh Onephim
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1E90FF)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildRecommendedCarousel(),
            const SizedBox(height: 16),
            buildCategorySelector(),
            const SizedBox(height: 12),
            buildMovieGrid(),
          ],
        ),
      ),
    );
  }
}
