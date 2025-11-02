import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isDarkMode = true;
  bool autoPlay = false;
  bool notifications = true;
  bool wifiOnly = true;

  void _toggleTheme(bool value) {
    setState(() => isDarkMode = value);
    final themeMode = value ? Brightness.dark : Brightness.light;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: themeMode == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  void _changeLanguage(Locale locale) {
    context.setLocale(locale);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          locale.languageCode == 'vi'
              ? 'switched_vi'.tr()
              : 'switched_en'.tr(),
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('cache_cleared'.tr()),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.grey : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('settings_title'.tr(), style: TextStyle(color: textColor)),
        backgroundColor: bgColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Appearance Section ---
          _buildSectionTitle('theme_section'.tr(), subTextColor),
          SwitchListTile(
            title: Text('dark_mode'.tr(), style: TextStyle(color: textColor)),
            subtitle: Text('dark_mode_desc'.tr(),
                style: TextStyle(color: subTextColor)),
            activeThumbColor: Colors.redAccent,
            value: isDarkMode,
            onChanged: _toggleTheme,
          ),
          const Divider(),

          // --- Language Section ---
          _buildSectionTitle('language_section'.tr(), subTextColor),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.redAccent),
            title: Text('language'.tr(), style: TextStyle(color: textColor)),
            subtitle: Text(
              context.locale.languageCode == 'vi'
                  ? "Tiếng Việt"
                  : "English",
              style: TextStyle(color: subTextColor),
            ),
            trailing: DropdownButton<Locale>(
              dropdownColor: Colors.grey[900],
              value: context.locale,
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(
                    value: Locale('vi'), child: Text("🇻🇳 Tiếng Việt")),
                DropdownMenuItem(
                    value: Locale('en'), child: Text("🇬🇧 English")),
              ],
              onChanged: (val) {
                if (val != null) _changeLanguage(val);
              },
            ),
          ),
          const Divider(),

          // --- Auto Play & Notifications ---
          _buildSectionTitle('play_section'.tr(), subTextColor),
          SwitchListTile(
            title: Text('auto_play'.tr(), style: TextStyle(color: textColor)),
            subtitle: Text('auto_play_desc'.tr(),
                style: TextStyle(color: subTextColor)),
            activeThumbColor: Colors.redAccent,
            value: autoPlay,
            onChanged: (val) => setState(() => autoPlay = val),
          ),
          SwitchListTile(
            title:
                Text('notifications'.tr(), style: TextStyle(color: textColor)),
            subtitle: Text('notifications_desc'.tr(),
                style: TextStyle(color: subTextColor)),
            activeThumbColor: Colors.redAccent,
            value: notifications,
            onChanged: (val) => setState(() => notifications = val),
          ),
          const Divider(),

          // --- Data & Storage ---
          _buildSectionTitle('storage_section'.tr(), subTextColor),
          SwitchListTile(
            title: Text('wifi_only'.tr(), style: TextStyle(color: textColor)),
            subtitle: Text('wifi_only_desc'.tr(),
                style: TextStyle(color: subTextColor)),
            activeThumbColor: Colors.redAccent,
            value: wifiOnly,
            onChanged: (val) => setState(() => wifiOnly = val),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: Text('clear_cache'.tr(), style: TextStyle(color: textColor)),
            onTap: _clearCache,
          ),
          const Divider(),

          // --- About / Info ---
          _buildSectionTitle('info_section'.tr(), subTextColor),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.redAccent),
            title: Text('app_version'.tr(), style: TextStyle(color: textColor)),
            subtitle: Text("1.0.0 (MovieApp)",
                style: TextStyle(color: subTextColor)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
