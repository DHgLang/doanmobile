import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart'; 
import '../services/api_service.dart';
import '../models/movie_model.dart';
import 'movie_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController searchController = TextEditingController();

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  
  List<Movie> searchResults = []; 
  bool isLoading = false; 

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  /// Khởi tạo và kiểm tra quyền micro
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Tìm kiếm phim và cập nhật danh sách kết quả
  void onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final results = await apiService.searchMovies(query, pages: 1); 
      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải kết quả tìm kiếm.')),
      );
    }
  }

  /// Chức năng tìm kiếm bằng giọng nói
  void startVoiceSearch() async {
    // Nếu đang lắng nghe, dừng lại
    if (_speechToText.isListening) {
      await _speechToText.stop();
      return; 
    }

    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            String spokenText = result.recognizedWords;
            searchController.text = spokenText;
            onSearchChanged(spokenText); 
          }
        },
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 3),
        localeId: 'vi_VN', 
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang lắng nghe... Hãy nói từ khóa tìm kiếm.'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể kích hoạt giọng nói. Vui lòng kiểm tra quyền micro.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    searchController.dispose();
    super.dispose();
  }

  /// Widget Thanh tìm kiếm
  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm series, phim, trò chơi...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
          suffixIcon: IconButton(
            icon: Icon(
              _speechToText.isListening ? Icons.mic_off : Icons.mic, 
              color: Colors.white
            ),
            onPressed: startVoiceSearch,
          ),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onSearchChanged,
        onSubmitted: onSearchChanged,
      ),
    );
  }

  /// Widget hiển thị kết quả tìm kiếm dưới dạng danh sách
  Widget buildSearchResultsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchResults.isEmpty && searchController.text.isNotEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Không tìm thấy kết quả phù hợp.', 
            style: TextStyle(color: Colors.white70)
          ),
        ),
      );
    }
    
    // Hiển thị tiêu đề "Series và phim được đề xuất" khi chưa nhập gì
    if (searchResults.isEmpty && searchController.text.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Series và phim được đề xuất', 
            style: TextStyle(
              color: Colors.white, 
              fontSize: 18, 
              fontWeight: FontWeight.bold
            )
          ),
        ),
      );
    }

    // Hiển thị danh sách kết quả
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final movie = searchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              'https://image.tmdb.org/t/p/w92${movie.posterPath}',
              width: 80, 
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, color: Colors.white54, size: 40),
            ),
          ),
          title: Text(
            movie.title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          // Đã sửa để đảm bảo chuỗi "Đang cập nhật" có màu xám
          subtitle: Text( 
            movie.releaseDate , 
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // Đã xóa 'title: Container()' để loại bỏ cảnh báo Dead code
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSearchBar(),
            const SizedBox(height: 12),
            buildSearchResultsList(),
          ],
        ),
      ),
    );
  }
}