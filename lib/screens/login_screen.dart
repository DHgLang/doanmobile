import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'verify_email_screen.dart';
import 'main_screen.dart';
import 'introduce_screen.dart';
// ✅ Import AppTheme. LƯU Ý: Nếu AppTheme không nằm cùng cấp,
// bạn cần thay đổi path (ví dụ: 'package:ten_package_cua_ban/config/theme.dart')

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;
  bool loading = false;

  Future<void> _submit() async {
    // 💡 Xử lý logic Đăng nhập/Đăng ký và xác thực Firebase
    setState(() => loading = true);
    try {
      if (isLogin) {
        // 🔹 Đăng nhập
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = userCredential.user;

        if (user != null) {
          if (!user.emailVerified) {
            // ignore: use_build_context_synchronously
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
              (route) => false,
            );
          } else {
            // ignore: use_build_context_synchronously
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
            );
          }
        }
      } else {
        // 🔹 Đăng ký
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user?.sendEmailVerification();

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gửi email xác thực, vui lòng kiểm tra Gmail!'),
          ),
        );

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Lỗi không xác định")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Scaffold tự động dùng backgroundColor từ AppTheme
      appBar: AppBar(
        // AppBar tự động dùng style từ AppTheme (primaryColor)
        title: Text(isLogin ? "Đăng nhập" : "Đăng ký"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const IntroduceScreen()),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon màu accentColor (Màu nhấn)
              Icon(
                Icons.movie_filter,
                size: 100,
                color: theme.colorScheme.secondary, // accentColor: 0xFFE94560
              ),
              const SizedBox(height: 40),

              // ✅ Trường Email - Tự động dùng Input Decoration Theme
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 20),

              // ✅ Trường Mật khẩu - Tự động dùng Input Decoration Theme
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(labelText: "Mật khẩu"),
              ),
              const SizedBox(height: 40),

              // ✅ Nút Đăng nhập/Đăng ký - Tự động dùng ElevatedButtonThemeData
              loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : SizedBox(
                      width: double.infinity,
                      // ElevatedButton tự động dùng style đã định nghĩa trong AppTheme (màu nền accentColor)
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(isLogin ? "Đăng nhập" : "Đăng ký"),
                      ),
                    ),
              const SizedBox(height: 20),

              // ✅ Nút chuyển đổi (màu trắng)
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin
                      ? "Chưa có tài khoản? Đăng ký"
                      : "Đã có tài khoản? Đăng nhập",
                  style: const TextStyle(
                    color: Colors.white, // Giữ màu trắng theo yêu cầu trước
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
