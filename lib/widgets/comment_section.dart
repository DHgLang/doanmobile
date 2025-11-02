import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class CommentSection extends StatefulWidget {
  final int movieId;
  const CommentSection({super.key, required this.movieId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  double _selectedRating = 0;
  String? _editingCommentId;
  final user = FirebaseAuth.instance.currentUser;

  CollectionReference get _commentRef => FirebaseFirestore.instance
      .collection('movies')
      .doc(widget.movieId.toString())
      .collection('comments');

  // 🧠 Thêm hoặc sửa bình luận
  Future<void> _uploadComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("enter_comment_rating_warning".tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      if (_editingCommentId == null) {
        await _commentRef.add({
          'comment': text,
          'rating': _selectedRating,
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user?.uid,
          'userName': user?.displayName ?? 'anonymous_user'.tr(),
          'userAvatar': user?.photoURL,
        });
      } else {
        await _commentRef.doc(_editingCommentId).update({
          'comment': text,
          'rating': _selectedRating,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _editingCommentId = null;
      }

      _commentController.clear();
      setState(() => _selectedRating = 0);
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('error_occurred'.tr(args: [e.toString()]))));
    }
  }

  // ❌ Xóa bình luận
  Future<void> _deleteComment(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('delete_comment'.tr()),
        content: Text('delete_comment_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
    if (confirm == true) await _commentRef.doc(id).delete();
  }

  // ✏️ Chỉnh sửa
  void _editComment(String id, String comment, double rating) {
    setState(() {
      _editingCommentId = id;
      _commentController.text = comment;
      _selectedRating = rating;
    });
  }

  // ⭐ Giao diện chọn sao
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            starIndex <= _selectedRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
          onPressed: () =>
              setState(() => _selectedRating = starIndex.toDouble()),
        );
      }),
    );
  }

  // ⭐ Hiển thị trung bình số sao
  Widget _buildAverageRating() {
    return StreamBuilder<QuerySnapshot>(
      stream: _commentRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            'no_ratings'.tr(),
            style: const TextStyle(color: Colors.white70),
          );
        }
        final ratings = snapshot.data!.docs
            .map((doc) => (doc['rating'] ?? 0).toDouble())
            .toList();
        final avg = ratings.reduce((a, b) => a + b) / ratings.length;
        return Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '${avg.toStringAsFixed(1)} / 5 (${ratings.length} ${'votes'.tr()})',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'comments_section'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          _buildAverageRating(),
          const SizedBox(height: 10),
          _buildStarRating(),
          const SizedBox(height: 8),

          // ✍️ Ô nhập bình luận
          TextField(
            controller: _commentController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: _editingCommentId == null
                  ? 'enter_comment_hint'.tr()
                  : 'editing_comment_hint'.tr(),
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[850],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _editingCommentId == null ? Icons.send : Icons.check,
                  color: Colors.redAccent,
                ),
                onPressed: _uploadComment,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // 📡 Danh sách bình luận realtime
          StreamBuilder<QuerySnapshot>(
            stream: _commentRef
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text(
                  'no_comments'.tr(),
                  style: const TextStyle(color: Colors.white54),
                );
              }

              final comments = snapshot.data!.docs;
              return ListView.builder(
                itemCount: comments.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final doc = comments[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final id = doc.id;
                  final comment = data['comment'] ?? '';
                  final rating = (data['rating'] ?? 0).toDouble();
                  final userName = data['userName'] ?? 'anonymous_user'.tr();
                  final userAvatar = data['userAvatar'];
                  final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                  final canEdit = data['userId'] == user?.uid;

                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: userAvatar != null
                            ? NetworkImage(userAvatar)
                            : null,
                        child: userAvatar == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comment,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (timestamp != null)
                            Text(
                              '${timestamp.day}/${timestamp.month}/${timestamp.year} - ${timestamp.hour}:${timestamp.minute}',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      trailing: canEdit
                          ? PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white70,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editComment(id, comment, rating);
                                } else if (value == 'delete') {
                                  _deleteComment(id);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('edit'.tr()),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('delete'.tr()),
                                ),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
