import 'dart:ui';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:words_and_hammers/games/main_game.dart';

class GamePage extends StatefulWidget {
  final int level;
  final int earnedPoint;
  final bool tutorialLevel;
  final int? tutorialLevelIndex;

  const GamePage({
    super.key,
    required this.level,
    required this.earnedPoint,
    this.tutorialLevel = false,
    this.tutorialLevelIndex,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  MainGame? mainGame;
  HammerType selectedHammerType = HammerType.none;
  bool isHammerMenuOpen = false;
  bool isTouchable = false;
  int tutorialStep = 0;

  void nextTutorialStep() {
    setState(() {
      tutorialStep++;
      if (tutorialStep == 2 &&
          widget.tutorialLevelIndex == 1 &&
          mainGame != null &&
          mainGame!.validWords.isNotEmpty &&
          !mainGame!.isTutorialAnimating) {
        mainGame!.startTutorialAnimation(mainGame!.validWords.first.path);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;
      final double statusBarHeight = MediaQuery.of(context).padding.top;

      setState(() {
        mainGame = MainGame(
          level: widget.level,
          earnedPoint: widget.earnedPoint,
          statusBarHeight: statusBarHeight,
          tutorialLevel: widget.tutorialLevel,
          tutorialLevelIndex: widget.tutorialLevelIndex,
          onTutorialAnimUpdate: () {
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() {});
              });
            }
          },
          onLevelComplete: () {
            if (widget.tutorialLevel && tutorialStep == 3) {
              setState(() {
                tutorialStep = 4;
              });
            } else {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.06,
                          bottom: screenHeight * 0.06,
                          right: screenWidth * 0.08,
                          left: screenWidth * 0.08,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Tebrikler!",
                              style: TextStyle(
                                fontSize: screenWidth * 0.075,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                              textScaler: const TextScaler.linear(1),
                            ),
                            Text(
                              "Bölüm ${widget.level} tamamlandı!\n"
                              "Toplam Skorunuz: ${mainGame!.earnedPoint}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                              textScaler: const TextScaler.linear(1),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withValues(
                                  alpha: 0.25,
                                ),
                                foregroundColor: Colors.black,
                                shadowColor: Colors.black.withValues(
                                  alpha: 0.2,
                                ),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.only(
                                  top: screenHeight * 0.011,
                                  bottom: screenHeight * 0.011,
                                  left: screenWidth * 0.075,
                                  right: screenWidth * 0.075,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pop(context, mainGame!.earnedPoint);
                              },
                              child: Text(
                                'Bölümü Kapat',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                textScaler: const TextScaler.linear(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        );
        mainGame!.selectedHammerType = selectedHammerType;
      });
    });

    if (!widget.tutorialLevel) {
      isTouchable = true;
      if (kDebugMode) {
        print("NORMAL BÖLÜM AÇILDI!");
      }
    } else {
      if (kDebugMode) {
        print("TUTORİAL BÖLÜM AÇILDI!");
      }
    }
  }

  Widget _buildHammerOption(HammerType type, String label) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isSelectedOptionCurrentlyActive = selectedHammerType == type;

    Color getOptionColor(HammerType optionType) {
      switch (optionType) {
        case HammerType.none:
          return Colors.green;
        case HammerType.singleTile:
          return Colors.orange;
        case HammerType.fullRow:
          return Colors.red;
        case HammerType.fullColumn:
          return Colors.cyan;
      }
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHammerType = type;
          mainGame!.selectedHammerType = type;
          isHammerMenuOpen = false;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.015,
        ),
        decoration: BoxDecoration(
          color: isSelectedOptionCurrentlyActive
              ? getOptionColor(type)
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.035,
          ),
          textAlign: TextAlign.center,
          textScaler: const TextScaler.linear(1),
        ),
      ),
    );
  }

  Color _getActiveButtonColor() {
    switch (selectedHammerType) {
      case HammerType.none:
        return Colors.green;
      case HammerType.singleTile:
        return Colors.orange;
      case HammerType.fullRow:
        return Colors.red;
      case HammerType.fullColumn:
        return Colors.cyan;
    }
  }

  Color _getPanelBorderColor() {
    switch (selectedHammerType) {
      case HammerType.none:
        return Colors.green.shade300;
      case HammerType.singleTile:
        return Colors.orange.shade300;
      case HammerType.fullRow:
        return Colors.red.shade300;
      case HammerType.fullColumn:
        return Colors.cyan.shade300;
    }
  }

  Color _getPanelBackgroundColor() {
    return const Color(0xFF1E242B);
  }

  String _getActiveButtonText() {
    switch (selectedHammerType) {
      case HammerType.none:
        return 'Aktif Mod: Kelime Seçimi';
      case HammerType.singleTile:
        return 'Aktif Mod: Hücresel Çekiç';
      case HammerType.fullRow:
        return 'Aktif Mod: Satır Çekici';
      case HammerType.fullColumn:
        return 'Aktif Mod: Sütun Çekici';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Flamegame alanına gönderi
            Padding(
              padding: EdgeInsets.only(top: statusBarHeight),
              child: mainGame == null
                  ? const SizedBox.shrink()
                  : GameWidget(game: mainGame!),
            ),
            if (!isTouchable)
              Container(
                width: screenWidth,
                height: screenHeight,
                color: Colors.transparent,
              ),
            // Tutorial Bölümü 1 - Adım 1: Hoşgeldiniz Çıktısı
            if (widget.tutorialLevel &&
                widget.tutorialLevelIndex == 1 &&
                tutorialStep == 0)
              Positioned(
                top: (screenHeight * 0.1) + statusBarHeight,
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Words & Hammers'a Hoşgeldiniz!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Oyundaki amaç, ekrandaki harfleri birleştirerek anlamlı kelimeler oluşturmak ve puan kazanarak ilerlemektir. Başlamadan önce size bazı basit kuralları anlatacağız.",
                        style: TextStyle(
                          fontSize: screenWidth * 0.042,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton(
                        onPressed: nextTutorialStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.018,
                          ),
                        ),
                        child: Text(
                          "Devam Et",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          textScaler: const TextScaler.linear(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Tutorial Bölümü 1 - Adım 2: Oyun Mekaniklerinin Anlatılması
            if (widget.tutorialLevel &&
                widget.tutorialLevelIndex == 1 &&
                tutorialStep == 1)
              Positioned(
                top: (screenHeight * 0.1) + statusBarHeight,
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Harfleri Birleştirerek Kelime Oluştur!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Kelime oluştururken 2 temel kural vardır: Kelimeye yalnızca en alt satırdan başlayabilirsin. Harfleri seçerken sadece yukarı, aşağı, sağa veya sola doğru ilerleyebilirsin; çapraz seçim yapılamaz. Her kelime düz yazılır, yani tersten veya karışık şekilde yazılamaz.\n\n"
                        "Şimdi bir örnek ile kelime oluşturma işlemini gösterelim.",
                        style: TextStyle(
                          fontSize: screenWidth * 0.042,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton(
                        onPressed: nextTutorialStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.018,
                          ),
                        ),
                        child: Text(
                          "Devam Et",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          textScaler: const TextScaler.linear(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Tutorial Bölümü 1 - Adım 3: Oyun Mekaniklerinin Gösterilmesi
            if (widget.tutorialLevel &&
                widget.tutorialLevelIndex == 1 &&
                tutorialStep == 2 &&
                mainGame != null) ...[
              // Animasyonlu İşaretçi Çizgisi İzi
              if (mainGame!.tutorialTrail.length > 1)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _TrailPainter(
                        mainGame!.tutorialTrail,
                        statusBarHeight,
                      ),
                    ),
                  ),
                ),
              // Animasyonlu İşaretçi
              if (mainGame!.isTutorialAnimating &&
                  mainGame!.tutorialCurrentPosition != null)
                Positioned(
                  left:
                      mainGame!.tutorialCurrentPosition!.x -
                      screenWidth * 0.125,
                  top:
                      mainGame!.tutorialCurrentPosition!.y -
                      screenWidth * 0.075 +
                      statusBarHeight,
                  child: Icon(
                    Icons.arrow_drop_up_sharp,
                    size: screenWidth * 0.25,
                    color: Colors.deepOrange.shade900,
                  ),
                ),
              // Adım 3 Popup Mesajı
              Positioned(
                top: (screenHeight * 0.1) + statusBarHeight,
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Kelime Seçim Örneği",
                        style: TextStyle(
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Aşağıdaki animasyon kelime seçiminin nasıl yapıldığını gösteriyor. Lütfen işaretçi ve beraberindeki izi takip et!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.042,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            mainGame!.stopTutorialAnimation();
                            tutorialStep = 3;
                            isTouchable = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.018,
                          ),
                        ),
                        child: Text(
                          "Anladım",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          textScaler: const TextScaler.linear(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Tutorial Bölümü 1 - Adım 4: İplerin Oyuncuya Bırakıldığı An
            if (widget.tutorialLevel &&
                widget.tutorialLevelIndex == 1 &&
                tutorialStep == 3)
              Positioned(
                top: (screenHeight * 0.1) + statusBarHeight,
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Şimdi Deneme Zamanı!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Aynı yolu izleyerek kelimeyi seçmeye çalış!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.042,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                    ],
                  ),
                ),
              ),
            // Tutorial Bölümü 1 - Adım 5: Tebrik Mesajı ve Eğitimin Sonlandırılması
            if (widget.tutorialLevel &&
                widget.tutorialLevelIndex == 1 &&
                tutorialStep == 4)
              Positioned(
                top: (screenHeight * 0.1) + statusBarHeight,
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Tebrikler!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "İlk eğitim bölümünü başarıyla tamamladın! Artık kelime seçimini biliyorsun. Bir sonraki eğitime geçmeyi unutma!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.042,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.018,
                          ),
                        ),
                        child: Text(
                          "1. Eğitimi Bitir!",
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          textScaler: const TextScaler.linear(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Özel Çekiç Seçimi için Açılır panel
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              bottom: screenHeight * 0.1,
              right: isHammerMenuOpen ? screenWidth * 0.05 : -(screenWidth * 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    width: screenWidth * 0.75,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: _getPanelBackgroundColor().withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _getPanelBorderColor(),
                        width: screenWidth * 0.005,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHammerOption(
                          HammerType.fullColumn,
                          'Sütun Çekici Modu',
                        ),
                        _buildHammerOption(
                          HammerType.fullRow,
                          'Satır Çekici Modu',
                        ),
                        _buildHammerOption(
                          HammerType.singleTile,
                          'Hücresel Çekiç Modu',
                        ),
                        _buildHammerOption(
                          HammerType.none,
                          'Kelime Seçim Modu',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Sayfadan ayrılma butonu
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  top: (screenHeight * 0.02 + statusBarHeight),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.red.withValues(alpha: 0.9),
                    highlightColor: Colors.red.withValues(alpha: 0.75),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    customBorder: const CircleBorder(),
                    child: Transform.rotate(
                      angle: pi / 4,
                      child: Icon(
                        Icons.add_circle,
                        size: screenWidth * 0.1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Aktif Mod Butonu
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isHammerMenuOpen = !isHammerMenuOpen;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getActiveButtonColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.0125,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.construction, color: Colors.black),
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        _getActiveButtonText(),
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  final List<Vector2> points;
  final double statusBarHeight;
  _TrailPainter(this.points, this.statusBarHeight);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = Colors.deepOrange.withValues(alpha: 0.75)
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(points[0].x, points[0].y + statusBarHeight);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y + statusBarHeight);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) => true;
}
