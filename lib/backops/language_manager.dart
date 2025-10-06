import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'tr';
  
  static LanguageManager? _instance;
  static LanguageManager get instance {
    _instance ??= LanguageManager._internal();
    return _instance!;
  }
  
  LanguageManager._internal();
  
  String _currentLanguage = _defaultLanguage;
  String get currentLanguage => _currentLanguage;
  
  // Dil değişikliği callback'i
  Function(String)? onLanguageChanged;
  
  // Mevcut dili yükle
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
  }
  
  // Dili değiştir ve kaydet
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      onLanguageChanged?.call(languageCode);
    }
  }
  
  // Desteklenen diller
  static const Map<String, String> supportedLanguages = {
    'tr': 'Türkçe',
    'en': 'English',
  };
  
  // Dil kodundan dil adını al
  String getLanguageName(String languageCode) {
    return supportedLanguages[languageCode] ?? languageCode;
  }
  
  // Mevcut dilin adını al
  String get currentLanguageName => getLanguageName(_currentLanguage);
}
