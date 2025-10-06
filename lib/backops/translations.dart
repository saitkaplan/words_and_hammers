import 'package:words_and_hammers/backops/language_manager.dart';

class Translations {
  static const Map<String, Map<String, String>> _translations = {
    'tr': {
      // Ana başlık
      'app_title': 'Words & Hammers',
      'app_subtitle': 'Muhteşem bir yolculuğa yelken aç!\n\nAma öncelikle bu yolculukta seni ve verilerini korumamız için giriş yapman gerekmekte!',
      
      // Form alanları
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'username': 'Kullanıcı Adı',
      'email': 'E-posta',
      'password': 'Şifre',
      'confirm_password': 'Şifre Tekrar',
      'remember_me': 'Beni Hatırla',
      'auto_login': 'Otomatik Giriş',
      'guest_continue': 'Misafir Olarak Devam Et',
      'or': 'veya',
      
      // Butonlar
      'google': 'Google',
      'apple': 'Apple',
      
      // Validasyon mesajları
      'username_required': 'Kullanıcı adı gerekli',
      'username_min_length': 'En az 3 karakter olmalı',
      'email_required': 'E-posta gerekli',
      'email_invalid': 'Geçerli bir e-posta girin',
      'password_required': 'Şifre gerekli',
      'password_min_length': 'En az 6 karakter olmalı',
      'confirm_password_required': 'Şifre tekrarı gerekli',
      'passwords_not_match': 'Şifreler eşleşmiyor',
      
      // Dialog mesajları
      'under_development': 'Geliştiriliyor',
      'feature_not_available': 'Bu özellik henüz geliştirilme aşamasında!',
      'use_guest_login': 'Lütfen şimdilik oyunu deneyimlemek için misafir girişini kullanabilirsiniz!',
      'understood': 'Anladım!',
      
      // Versiyon
      'version': 'Prototip 2 (Ver: 1.0.0)',
    },
    'en': {
      // Ana başlık
      'app_title': 'Words & Hammers',
      'app_subtitle': 'Set sail on an amazing journey!\n\nBut first, you need to log in to protect you and your data on this journey!',
      
      // Form alanları
      'login': 'Login',
      'register': 'Register',
      'username': 'Username',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'remember_me': 'Remember Me',
      'auto_login': 'Auto Login',
      'guest_continue': 'Continue as Guest',
      'or': 'or',
      
      // Butonlar
      'google': 'Google',
      'apple': 'Apple',
      
      // Validasyon mesajları
      'username_required': 'Username is required',
      'username_min_length': 'Must be at least 3 characters',
      'email_required': 'Email is required',
      'email_invalid': 'Please enter a valid email',
      'password_required': 'Password is required',
      'password_min_length': 'Must be at least 6 characters',
      'confirm_password_required': 'Password confirmation is required',
      'passwords_not_match': 'Passwords do not match',
      
      // Dialog mesajları
      'under_development': 'Under Development',
      'feature_not_available': 'This feature is still under development!',
      'use_guest_login': 'Please use guest login for now to experience the game!',
      'understood': 'Got it!',
      
      // Versiyon
      'version': 'Prototype 2 (Ver: 1.0.0)',
    },
  };
  
  static String get(String key, String languageCode) {
    return _translations[languageCode]?[key] ?? _translations['tr']![key] ?? key;
  }
  
  static String getCurrent(String key) {
    return get(key, LanguageManager.instance.currentLanguage);
  }
}
