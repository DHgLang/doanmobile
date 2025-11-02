import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie_model.dart';

class FavoritesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // LƯU Ý: Luôn kiểm tra FirebaseAuth.instance.currentUser != null trước khi dùng !
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> addFavorite(Movie movie) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(movie.id.toString())
        .set(movie.toMap()); // ✅ SỬ DỤNG toMap() ĐÃ CÓ TRONG MODEL CỦA BẠN
  }

  Future<void> removeFavorite(String id) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(id)
        .delete();
  }
  
  // ✅ THÊM HÀM BỊ THIẾU (SỬ DỤNG Stream mà bạn đã có)
  Future<List<Movie>> fetchFavoriteMovies() async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get(); // Dùng .get() thay vì .snapshots()

    return snapshot.docs
        .map((doc) => Movie.fromFirestore(doc.data())) // SỬ DỤNG fromFirestore() MỚI
        .toList();
  }

  Stream<List<Movie>> getFavorites() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map(
          // ✅ SỬ DỤNG fromFirestore() TỪ MODEL CỦA BẠN
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromFirestore(doc.data())).toList(),
        );
  }
}