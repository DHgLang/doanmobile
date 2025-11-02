import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:io';

class ManageProfileScreen extends StatefulWidget {
  const ManageProfileScreen({super.key});

  @override
  State<ManageProfileScreen> createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _displayNameController = TextEditingController();
  bool _isLoading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _displayNameController.text = _auth.currentUser?.displayName ?? '';
    _photoUrl = _auth.currentUser?.photoURL;
  }

  Future<void> _pickAndUploadImage() async {
    if (_isLoading) return;
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile == null) return;

    setState(() => _isLoading = true);
    final file = File(pickedFile.path);

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('${user.uid}.jpg');

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      setState(() {
        _photoUrl = downloadUrl;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('update_avatar_success'.tr())),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_upload_image'.tr())),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    if (_displayNameController.text.trim().isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('empty_name_warning'.tr())),
      );
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(_displayNameController.text.trim());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('update_profile_success'.tr())),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error_update_profile'.tr())),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _changePassword() {
    final userEmail = _auth.currentUser?.email;
    if (userEmail != null) {
      _auth.sendPasswordResetEmail(email: userEmail);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('password_reset_sent'.tr())),
      );
    }
  }

  // ✅ Hàm đổi ngôn ngữ
  void _toggleLanguage() async {
    final current = context.locale;
    final newLocale =
        current.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    await context.setLocale(newLocale);
    setState(() {}); // Làm mới giao diện
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _auth.currentUser?.email ?? 'no_email'.tr();
    final currentLang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('manage_profile'.tr(),
            style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Text(currentLang == 'vi' ? '🇬🇧' : '🇻🇳', style: const TextStyle(fontSize: 24)),
            tooltip: 'switch_language'.tr(),
            onPressed: _toggleLanguage,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileAvatar(),
              const SizedBox(height: 30),
              _buildReadOnlyField('Email', userEmail, Icons.email_outlined),
              const SizedBox(height: 20),
              _buildInputField(
                'display_name'.tr(),
                _displayNameController,
                Icons.person_outline,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.redAccent))
                  : ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'update_profile'.tr(),
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: _changePassword,
                child: Text(
                  'change_password'.tr(),
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[800],
            child: _photoUrl != null && _photoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      _photoUrl!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (_, __, ___) => _buildDefaultIcon(),
                    ),
                  )
                : _buildDefaultIcon(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isLoading ? null : _pickAndUploadImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIcon() {
    if (_auth.currentUser?.displayName != null &&
        _auth.currentUser!.displayName!.isNotEmpty) {
      return Text(
        _auth.currentUser!.displayName![0].toUpperCase(),
        style: const TextStyle(fontSize: 40, color: Colors.white),
      );
    }
    return const Icon(Icons.account_circle, color: Colors.white, size: 80);
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      style: const TextStyle(color: Colors.white70, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.redAccent),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}
