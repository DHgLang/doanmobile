import 'package:flutter/material.dart';
import '../models/movie_model.dart';

class MovieSlider extends StatelessWidget {
  final List<Movie> movies;
  const MovieSlider({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: movies.length,
        itemBuilder: (context, i) {
          final movie = movies[i];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(movie.backdropUrl),
                fit: BoxFit.cover,
              ),
            ),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(12),
            child: Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [Shadow(blurRadius: 8, color: Colors.black)],
              ),
            ),
          );
        },
      ),
    );
  }
}
