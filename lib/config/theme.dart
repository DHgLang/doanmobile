import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0F3460); // Màu nền AppBar
  static const Color accentColor = Color(
    0xFF4A90E2,
  ); // ✅ MÀU NHẤN MỚI: Xanh dương sáng
  static const Color backgroundColor = Color(0xFF16213E); // Màu nền Scaffold

  // Màu nền cho các Card/InputFields, dựa trên Input Decoration Theme trong code bạn cung cấp.
  // Color(0xFF1A1A2E) được dùng cho filled: true
  static const Color cardBackgroundColor = Color(0xFF1A1A2E);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.dark, // dùng tone tối kiểu Netflix
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor, // Sẽ dùng màu xanh dương mới
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),

    // Text
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineSmall: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Card
    cardTheme: const CardThemeData(
      color: cardBackgroundColor,
      shadowColor: Colors.black45,
      elevation: 3,
      margin: EdgeInsets.all(8),
    ),

    // BottomNavigationBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryColor,
      selectedItemColor: accentColor, // Sẽ dùng màu xanh dương mới
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),

    // InputDecoration cho ô tìm kiếm và các TextField khác
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBackgroundColor, // Màu nền của ô nhập liệu
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIconColor: Colors.white60,
      labelStyle: const TextStyle(
        color: Colors.white70,
      ), // Thêm style cho label
      floatingLabelBehavior: FloatingLabelBehavior.never, // Giữ label cố định
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18.0,
        horizontal: 15.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), // Giảm bo tròn để khớp với ảnh
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        // ✅ Focus border giờ là màu xanh dương mới
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
    ),

    // ElevatedButton Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            accentColor, // ✅ Nút Đăng nhập/Đăng ký dùng màu xanh dương mới
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        elevation: 5,
      ),
    ),
  );
}
