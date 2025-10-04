import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerData {
  final String playerId;
  final bool isGuest;
  final bool cloudSyncEnabled;
  final String lastSyncTime;
  final Map<String, dynamic> gameData;
  final Map<String, dynamic> cloudData;

  PlayerData({
    required this.playerId,
    required this.isGuest,
    required this.cloudSyncEnabled,
    required this.lastSyncTime,
    required this.gameData,
    required this.cloudData,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'isGuest': isGuest,
      'cloudSyncEnabled': cloudSyncEnabled,
      'lastSyncTime': lastSyncTime,
      'gameData': gameData,
      'cloudData': cloudData,
    };
  }

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      playerId: json['playerId'] ?? '',
      isGuest: json['isGuest'] ?? true,
      cloudSyncEnabled: json['cloudSyncEnabled'] ?? false,
      lastSyncTime: json['lastSyncTime'] ?? DateTime.now().toIso8601String(),
      gameData: Map<String, dynamic>.from(json['gameData'] ?? {}),
      cloudData: Map<String, dynamic>.from(json['cloudData'] ?? {}),
    );
  }

  PlayerData copyWith({
    String? playerId,
    bool? isGuest,
    bool? cloudSyncEnabled,
    String? lastSyncTime,
    Map<String, dynamic>? gameData,
    Map<String, dynamic>? cloudData,
  }) {
    return PlayerData(
      playerId: playerId ?? this.playerId,
      isGuest: isGuest ?? this.isGuest,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      gameData: gameData ?? this.gameData,
      cloudData: cloudData ?? this.cloudData,
    );
  }
}

class PlayerDataManager {
  static const String _fileName = 'player_data.json';
  static const String _backupFileName = 'player_data_backup.json';
  static const String _prefsKey = 'player_data_exists';

  // Singleton pattern
  static final PlayerDataManager _instance = PlayerDataManager._internal();
  factory PlayerDataManager() => _instance;
  PlayerDataManager._internal();

  PlayerData? _currentPlayerData;
  File? _playerDataFile;

  // Getters
  PlayerData? get currentPlayerData => _currentPlayerData;
  bool get hasPlayerData => _currentPlayerData != null;

  /// Oyuncu verilerini yükle
  Future<PlayerData?> loadPlayerData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _playerDataFile = File('${directory.path}/$_fileName');

      if (await _playerDataFile!.exists()) {
        final jsonString = await _playerDataFile!.readAsString();
        final jsonData = json.decode(jsonString);
        _currentPlayerData = PlayerData.fromJson(jsonData);
        return _currentPlayerData;
      }
      return null;
    } catch (e) {
      print('Player data yüklenirken hata: $e');
      return null;
    }
  }

  /// Yeni oyuncu verisi oluştur
  Future<PlayerData> createNewPlayerData({
    required bool isGuest,
    String? customPlayerId,
  }) async {
    try {
      final playerId = customPlayerId ?? _generatePlayerId();
      final now = DateTime.now().toIso8601String();

      _currentPlayerData = PlayerData(
        playerId: playerId,
        isGuest: isGuest,
        cloudSyncEnabled: !isGuest, // Misafir değilse cloud sync aktif
        lastSyncTime: now,
        gameData: {
          'totalScore': 0,
          'currentLevel': 1,
          'highestLevel': 1,
          'achievements': <String>[],
          'settings': {
            'soundEnabled': true,
            'musicEnabled': true,
            'vibrationEnabled': true,
          },
          'statistics': {
            'gamesPlayed': 0,
            'wordsFound': 0,
            'totalPlayTime': 0,
            'bestScore': 0,
          },
        },
        cloudData: {
          'firebaseUserId': null,
          'appleUserId': null,
          'syncStatus': 'pending',
          'lastCloudUpdate': null,
        },
      );

      await savePlayerData();
      await _markPlayerDataExists();
      return _currentPlayerData!;
    } catch (e) {
      print('Yeni oyuncu verisi oluşturulurken hata: $e');
      rethrow;
    }
  }

  /// Oyuncu verilerini kaydet
  Future<bool> savePlayerData() async {
    if (_currentPlayerData == null) return false;

    try {
      final directory = await getApplicationDocumentsDirectory();
      _playerDataFile = File('${directory.path}/$_fileName');

      // Backup oluştur
      if (await _playerDataFile!.exists()) {
        final backupFile = File('${directory.path}/$_backupFileName');
        await _playerDataFile!.copy(backupFile.path);
      }

      // Ana dosyayı kaydet
      final jsonString = json.encode(_currentPlayerData!.toJson());
      await _playerDataFile!.writeAsString(jsonString);

      print('Oyuncu verileri başarıyla kaydedildi: ${_playerDataFile!.path}');
      return true;
    } catch (e) {
      print('Oyuncu verileri kaydedilirken hata: $e');
      return false;
    }
  }

  /// Oyun verilerini güncelle
  Future<bool> updateGameData(Map<String, dynamic> updates) async {
    if (_currentPlayerData == null) return false;

    try {
      _currentPlayerData = _currentPlayerData!.copyWith(
        gameData: {..._currentPlayerData!.gameData, ...updates},
        lastSyncTime: DateTime.now().toIso8601String(),
      );

      return await savePlayerData();
    } catch (e) {
      print('Oyun verileri güncellenirken hata: $e');
      return false;
    }
  }

  /// Skor güncelle
  Future<bool> updateScore(int newScore) async {
    if (_currentPlayerData == null) return false;

    final currentScore = _currentPlayerData!.gameData['totalScore'] ?? 0;
    final bestScore =
        _currentPlayerData!.gameData['statistics']['bestScore'] ?? 0;

    return await updateGameData({
      'totalScore': currentScore + newScore,
      'statistics': {
        ..._currentPlayerData!.gameData['statistics'] ?? {},
        'bestScore': newScore > bestScore ? newScore : bestScore,
      },
    });
  }

  /// Seviye güncelle
  Future<bool> updateLevel(int newLevel) async {
    if (_currentPlayerData == null) return false;

    final highestLevel = _currentPlayerData!.gameData['highestLevel'] ?? 1;

    return await updateGameData({
      'currentLevel': newLevel,
      'highestLevel': newLevel > highestLevel ? newLevel : highestLevel,
    });
  }

  /// İstatistik güncelle
  Future<bool> updateStatistics(Map<String, dynamic> stats) async {
    if (_currentPlayerData == null) return false;

    final currentStats = _currentPlayerData!.gameData['statistics'] ?? {};

    return await updateGameData({
      'statistics': {...currentStats, ...stats},
    });
  }

  /// Oyuncu verilerini sil
  Future<bool> deletePlayerData() async {
    try {
      if (_playerDataFile != null && await _playerDataFile!.exists()) {
        await _playerDataFile!.delete();
      }

      _currentPlayerData = null;
      await _clearPlayerDataExists();

      print('Oyuncu verileri silindi');
      return true;
    } catch (e) {
      print('Oyuncu verileri silinirken hata: $e');
      return false;
    }
  }

  /// Backup'tan geri yükle
  Future<bool> restoreFromBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupFile = File('${directory.path}/$_backupFileName');

      if (await backupFile.exists()) {
        final jsonString = await backupFile.readAsString();
        final jsonData = json.decode(jsonString);
        _currentPlayerData = PlayerData.fromJson(jsonData);

        // Ana dosyayı backup ile değiştir
        _playerDataFile = File('${directory.path}/$_fileName');
        await backupFile.copy(_playerDataFile!.path);

        print('Backup\'tan geri yüklendi');
        return true;
      }
      return false;
    } catch (e) {
      print('Backup\'tan geri yüklenirken hata: $e');
      return false;
    }
  }

  /// Dosya yolu al
  Future<String?> getPlayerDataPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      return await file.exists() ? file.path : null;
    } catch (e) {
      print('Dosya yolu alınırken hata: $e');
      return null;
    }
  }

  /// Benzersiz oyuncu ID'si oluştur
  String _generatePlayerId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'player_${timestamp}_$random';
  }

  /// Oyuncu verisi var mı işaretle
  Future<bool> _markPlayerDataExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);
      return true;
    } catch (e) {
      print('SharedPreferences kaydedilirken hata: $e');
      return false;
    }
  }

  /// Oyuncu verisi var mı işaretini temizle
  Future<bool> _clearPlayerDataExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      return true;
    } catch (e) {
      print('SharedPreferences temizlenirken hata: $e');
      return false;
    }
  }

  /// Oyuncu verisi var mı kontrol et
  Future<bool> hasPlayerDataFile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefsKey) ?? false;
    } catch (e) {
      print('SharedPreferences okunurken hata: $e');
      return false;
    }
  }

  /// Oyun başlatıldığında çağrılacak
  Future<void> onGameStart() async {
    if (_currentPlayerData == null) return;

    await updateStatistics({
      'gamesPlayed':
          (_currentPlayerData!.gameData['statistics']['gamesPlayed'] ?? 0) + 1,
    });
  }

  /// Oyun bittiğinde çağrılacak
  Future<void> onGameEnd({
    required int score,
    required int level,
    required int wordsFound,
    required int playTimeSeconds,
  }) async {
    if (_currentPlayerData == null) return;

    await updateGameData({
      'totalScore': (_currentPlayerData!.gameData['totalScore'] ?? 0) + score,
      'currentLevel': level,
      'highestLevel':
          level > (_currentPlayerData!.gameData['highestLevel'] ?? 1)
          ? level
          : (_currentPlayerData!.gameData['highestLevel'] ?? 1),
      'statistics': {
        ..._currentPlayerData!.gameData['statistics'] ?? {},
        'wordsFound':
            (_currentPlayerData!.gameData['statistics']['wordsFound'] ?? 0) +
            wordsFound,
        'totalPlayTime':
            (_currentPlayerData!.gameData['statistics']['totalPlayTime'] ?? 0) +
            playTimeSeconds,
        'bestScore':
            score >
                (_currentPlayerData!.gameData['statistics']['bestScore'] ?? 0)
            ? score
            : (_currentPlayerData!.gameData['statistics']['bestScore'] ?? 0),
      },
    });
  }

  /// Ayarları güncelle
  Future<bool> updateSettings(Map<String, dynamic> settings) async {
    if (_currentPlayerData == null) return false;

    return await updateGameData({
      'settings': {
        ..._currentPlayerData!.gameData['settings'] ?? {},
        ...settings,
      },
    });
  }

  /// Başarı ekle
  Future<bool> addAchievement(String achievementId) async {
    if (_currentPlayerData == null) return false;

    final achievements = List<String>.from(
      _currentPlayerData!.gameData['achievements'] ?? [],
    );
    if (!achievements.contains(achievementId)) {
      achievements.add(achievementId);
      return await updateGameData({'achievements': achievements});
    }
    return true;
  }
}
