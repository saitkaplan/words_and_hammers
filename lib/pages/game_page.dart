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

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  MainGame? mainGame;
  HammerType selectedHammerType = HammerType.none;
  bool isHammerMenuOpen = false;
  bool isTouchable = false;
  int tutorialStep = 0;
  HammerRarity selectedRarity = HammerRarity.rare;
  bool frameVisible = false;
  late AnimationController hammerPulseController;
  late AnimationController xPulseController;

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
    hammerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 1.0,
      upperBound: 1.18,
    )..repeat(reverse: true);
    xPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 1.0,
      upperBound: 1.22,
    )..repeat(reverse: true);
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
          onGridShifted: () {
            if (widget.tutorialLevel &&
                widget.tutorialLevelIndex == 2 &&
                tutorialStep == 4) {
              setState(() {
                tutorialStep = 5;
              });
            }
          },
        );
        mainGame!.selectedHammerType = selectedHammerType;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          frameVisible = true;
        });
      });
      if (widget.tutorialLevel && widget.tutorialLevelIndex == 2) {
        setState(() {
          selectedHammerType = HammerType.none;
          mainGame?.selectedHammerType = HammerType.none;
        });
      }
    });

    if (widget.tutorialLevel) {
      isTouchable = true;
      if (kDebugMode) {
        print("TUTORİAL BÖLÜM AÇILDI!");
      }
    } else {
      if (kDebugMode) {
        print("NORMAL BÖLÜM AÇILDI!");
      }
    }
  }

  @override
  void dispose() {
    hammerPulseController.dispose();
    xPulseController.dispose();
    super.dispose();
  }

  void onHammerUsed() {
    if (widget.tutorialLevel &&
        widget.tutorialLevelIndex == 2 &&
        tutorialStep == 4) {
      setState(() {
        tutorialStep = 5;
      });
    }
  }

  Widget _buildHammerOption(HammerType type, [String? labelOverride]) {
    final info = hammerInfoMap[type];
    if (info == null) return const SizedBox.shrink();
    final bool isSpecial = allSpecialHammers.contains(type);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _ModQuickButton(
            hammerType: type,
            label: labelOverride ?? info.label,
            isActive: selectedHammerType == type,
            onTap: () {
              setState(() {
                selectedHammerType = type;
                mainGame?.selectedHammerType = type;
                isHammerMenuOpen = false;
              });
            },
            color: info.color,
            tooltip: info.label,
            bounceOnTap: false,
            showIcon: !isSpecial,
          ),
        ),
        IconButton(
          icon: Icon(Icons.info, color: info.color, size: 22),
          splashRadius: 20,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                final double screenWidth = MediaQuery.of(context).size.width;
                final double screenHeight = MediaQuery.of(context).size.height;
                return Dialog(
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
                              "${info.label}\nKullanımı",
                              style: TextStyle(
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              textScaler: const TextScaler.linear(1),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            HammerPatternGrid(
                              pattern: getHammerPattern(type),
                              color: info.color,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              "Burada çekicin kullanım sonrası oyun alanından kaldıracağı karelerin bilgisi verilmektedir.\n\nLütfen dikkatlice inceleyiniz!",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              textScaler: const TextScaler.linear(1),
                            ),
                            SizedBox(height: screenHeight * 0.02),
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
                              },
                              child: Text(
                                'Anladım!',
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
                );
              },
            );
          },
        ),
      ],
    );
  }

  Color _getPanelBorderColor() {
    final info = hammerInfoMap[selectedHammerType];
    return info?.borderColor ?? Colors.grey.shade300;
  }

  Color _getPanelBackgroundColor() {
    return const Color(0xFF1E242B);
  }

  Color getFrameColor() {
    if (!frameVisible) return Colors.transparent;
    if (selectedHammerType == HammerType.none) {
      return Colors.green;
    } else if (selectedHammerType == HammerType.singleTile) {
      return Colors.red;
    } else {
      return hammerInfoMap[selectedHammerType]?.color ?? Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final bool isTutorial2 =
        widget.tutorialLevel && widget.tutorialLevelIndex == 2;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Flame Oyun Alanı Gönderisi
            Padding(
              padding: EdgeInsets.only(top: statusBarHeight),
              child: mainGame == null
                  ? const SizedBox.shrink()
                  : GameWidget(game: mainGame!),
            ),
            if (isTouchable)
              Container(
                width: screenWidth,
                height: screenHeight,
                color: Colors.transparent,
              ),
            // Tutorial Bölümü 1 - Adım 1: Hoşgeldiniz!
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
            // Tutorial Bölümü 1 - Adım 2: Oyun Mekanikleri 1!
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
                        "Kelime oluştururken 2 temel kural vardır: Kelimeye yalnızca en alt satırdan başlayabilirsin. Harfleri seçerken sadece yukarı, aşağı, sağa veya sola doğru ilerleyebilirsin; çapraz seçim yapılamaz. Her kelime düz yazılır, yani tersten veya karışık şekilde yazılamaz.\n\nŞimdi bir örnek ile kelime oluşturma işlemini gösterelim.",
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
            // Tutorial Bölümü 1 - Adım 3: Oyun Mekanikleri 2!
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
                            isTouchable = false;
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
            // Tutorial Bölümü 1 - Adım 4: Sıra Oyuncuda!
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
            // Tutorial Bölümü 1 - Adım 5: Tebrikler!
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
            // Tutorial 2 - Adım 1: Hoşgeldiniz!
            if (isTutorial2 && tutorialStep == 0)
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
                        "Çekiç Eğitimine Hoşgeldiniz!",
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
                        "Oyunun bir diğer önemli özelliği olan çekiçlerin nasıl kullanıldığını sizlere göstereceğiz.",
                        style: TextStyle(
                          fontSize: screenWidth * 0.042,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ElevatedButton(
                        onPressed: () => setState(() => tutorialStep = 1),
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
            // Tutorial 2 - Adım 2: Çekiç Seçimi!
            if (isTutorial2 && tutorialStep == 1)
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
                        "Önce Çekiç Seçimi!",
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
                        "Şimdi oyunu oynarken en çok kullanacağınız temel çekicimizi yani basit çekici seçme zamanı.",
                        style: TextStyle(
                          fontSize: screenWidth * 0.042,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      ScaleTransition(
                        scale: hammerPulseController,
                        child: _ModQuickButton(
                          hammerType: HammerType.singleTile,
                          label: 'Basit Çekiç',
                          isActive: true,
                          onTap: () {
                            setState(() {
                              selectedHammerType = HammerType.singleTile;
                              mainGame?.selectedHammerType =
                                  HammerType.singleTile;
                              tutorialStep = 2;
                            });
                          },
                          color: hammerInfoMap[HammerType.singleTile]!.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Tutorial 2 - Adım 3: Neden Çekiç Kullanılır?
            if (isTutorial2 && tutorialStep == 2)
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
                        "Neden Çekiç Kullanırız?",
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
                        "Çekiçler kelimelere ulaşmanın önemli bir yoludur. Oyunda kelime seçimlerine sadece en alt satırdan başlayabilirsiniz ve eğer en alt satırda seçilecek bir harf kalmadıysa burada sizlere yardım için devreye çekiçler girmekte.\n\nBirbirinden farklı çekiçleri kullanarak ve en alt satırdaki gereksiz harfleri temizleyerek daha üst satırlara erişim sağlayabilirsiniz.",
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
                            tutorialStep = 3;
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
            // Tutorial 2 - Adım 4: Çekiç Kullanımı Öncesi Gösterim!
            if (isTutorial2 && tutorialStep == 3)
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
                        "Çekici Kullanmadan Önce!",
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
                        "Doğru kelimeye erişmek için önce en alt satırdaki gereksiz harfleri temizlemelisin. Aşağıda işaretlenen kutuları çekicinle temizlemek için hazır mısın?",
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
                            tutorialStep = 4;
                            isTouchable = false;
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
                          "Hazırım",
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
            // Tutorial 2 - Adım 4: Kutu Gösterim Animasyonları!
            if (isTutorial2 && tutorialStep == 3)
              ..._buildXPulseAnimation(context, showOnly: true),
            // Tutorial 2 - Adım 5: Çekiç Kullanımı Oyuncuda!
            if (isTutorial2 && tutorialStep == 4)
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
                        "Şimdi Çekici Kullan!",
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
                        "En alt satırdaki gereksiz harfleri temizle!",
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
            // Tutorial 2 - Adım 6: Kelimeye Erişildi!
            if (isTutorial2 && tutorialStep == 5)
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
                        "Kelimeye Eriştin!",
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
                        "Artık kelimeyi seçebilirsin.\n\nBunun için ilk önce kelime seçim modunu aktif et!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.042,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ScaleTransition(
                        scale: hammerPulseController,
                        child: _ModQuickButton(
                          hammerType: HammerType.none,
                          label: 'Kelime Seç',
                          isActive: true,
                          onTap: () {
                            setState(() {
                              selectedHammerType = HammerType.none;
                              mainGame?.selectedHammerType = HammerType.none;
                              tutorialStep = 6;
                            });
                          },
                          color: Colors.green,
                          icon: Icons.edit,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Tutorial 2 - Adım 7: Çekiç Kullanımı Ardından Kelime Seçimi!
            if (isTutorial2 && tutorialStep == 7)
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
                        "Son Adım!",
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
                        "Artık kelimeyi seçebilirsin!",
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
            // Aktif Mod Butonları
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Seçim Modu Butonu
                    _ModQuickButton(
                      hammerType: HammerType.none,
                      label: 'Kelime Seç',
                      isActive: selectedHammerType == HammerType.none,
                      onTap: () {
                        setState(() {
                          selectedHammerType = HammerType.none;
                          mainGame?.selectedHammerType = HammerType.none;
                          isHammerMenuOpen = false;
                        });
                      },
                      color: Colors.green,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    // Basit Çekiç Modu Butonu
                    _ModQuickButton(
                      hammerType: HammerType.singleTile,
                      label: 'Basit Çekiç',
                      isActive: selectedHammerType == HammerType.singleTile,
                      onTap: () {
                        setState(() {
                          selectedHammerType = HammerType.singleTile;
                          mainGame?.selectedHammerType = HammerType.singleTile;
                          isHammerMenuOpen = false;
                        });
                      },
                      color: Colors.red,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    // Özel Çekiçler Butonu
                    _ModQuickButton(
                      icon: Icons.more_horiz,
                      label: '',
                      isActive: allSpecialHammers.contains(selectedHammerType),
                      onTap: () {
                        setState(() {
                          isHammerMenuOpen = !isHammerMenuOpen;
                        });
                      },
                      color:
                          hammerInfoMap[selectedHammerType]?.color ??
                          Colors.blueGrey,
                      tooltip: 'Özel Çekiçler',
                      bounceOnTap: true,
                    ),
                  ],
                ),
              ),
            ),
            // Özel Çekiçler Paneli
            AnimatedPositioned(
              duration: const Duration(milliseconds: 125),
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
                        // Seçili nadirliğe göre çekiçler
                        ...allSpecialHammers
                            .where((h) => getHammerRarity(h) == selectedRarity)
                            .map(
                              (h) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: screenHeight * 0.008,
                                ),
                                child: _buildHammerOption(h),
                              ),
                            ),
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (final rarity in [
                                HammerRarity.rare,
                                HammerRarity.epic,
                                HammerRarity.legendary,
                                HammerRarity.mystic,
                              ])
                                _RarityTabButton(
                                  rarity: rarity,
                                  isSelected: selectedRarity == rarity,
                                  onTap: () {
                                    setState(() {
                                      selectedRarity = rarity;
                                    });
                                  },
                                ),
                            ],
                          ),
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
                      setState(() {
                        frameVisible = false;
                      });
                      Future.delayed(const Duration(milliseconds: 400), () {
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      });
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
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    border: Border.all(color: getFrameColor(), width: 3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildXPulseAnimation(
    BuildContext context, {
    bool showOnly = false,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    if (mainGame == null || mainGame!.grid.isEmpty) return [];
    final grid = mainGame!.grid;
    List<List<int>> xPositions = [];
    int row = grid.length - 1;
    for (int col = 0; col < grid[row].length; col++) {
      if (grid[row][col].toUpperCase() == 'X') {
        xPositions.add([row, col]);
      }
    }
    return [
      if (!showOnly)
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
                  "Çekici Kullan!",
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
                  "Artık çekici neden kullanman gerektiğini öğrendin. Şimdi kullanma vakti.",
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
      for (final pos in xPositions)
        Builder(
          builder: (context) {
            final center = mainGame!.tileCenterPosition(pos[0], pos[1]);
            final double radius = screenWidth * 0.09;
            return Positioned(
              left: center.x - radius,
              top: center.y - radius + statusBarHeight,
              child: ScaleTransition(
                scale: xPulseController,
                child: Container(
                  width: radius * 2,
                  height: radius * 2,
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.7),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "X",
                      style: TextStyle(
                        fontSize: screenWidth * 0.09,
                        fontWeight: FontWeight.bold,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
    ];
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

// Rarity enum ve yardımcı fonksiyonlar
enum HammerRarity { common, rare, epic, legendary, mystic }

String getRarityLabel(HammerRarity rarity) {
  switch (rarity) {
    case HammerRarity.common:
      return 'Sıradan';
    case HammerRarity.rare:
      return 'Nadir';
    case HammerRarity.epic:
      return 'Epik';
    case HammerRarity.legendary:
      return 'Efsanevi';
    case HammerRarity.mystic:
      return 'Mistik';
  }
}

Color getRarityColor(HammerRarity rarity) {
  switch (rarity) {
    case HammerRarity.common:
      return Colors.grey;
    case HammerRarity.rare:
      return Colors.green;
    case HammerRarity.epic:
      return Colors.blue;
    case HammerRarity.legendary:
      return Colors.orange;
    case HammerRarity.mystic:
      return Colors.purple;
  }
}

HammerRarity getHammerRarity(HammerType type) {
  final info = hammerInfoMap[type];
  return info?.rarity ?? HammerRarity.common;
}

final List<HammerType> allSpecialHammers = [
  HammerType.fullColumn,
  HammerType.fullRow,
  HammerType.xHammer,
  HammerType.positiveHammer,
  HammerType.smallSledgeHammer,
  HammerType.bigSledgeHammer,
  HammerType.rightDuo,
  HammerType.downDuo,
  HammerType.leftDuo,
  HammerType.upDuo,
  HammerType.horizontalTrio,
  HammerType.verticalTrio,
  HammerType.diagonalLeft,
  HammerType.diagonalRight,
];

List<List<int>> getHammerPattern(HammerType type) {
  switch (type) {
    case HammerType.horizontalTrio:
      return [
        [1, 2, 1],
      ];
    case HammerType.verticalTrio:
      return [
        [1],
        [2],
        [1],
      ];
    case HammerType.diagonalLeft:
      return [
        [1, 0, 0],
        [0, 2, 0],
        [0, 0, 1],
      ];
    case HammerType.diagonalRight:
      return [
        [0, 0, 1],
        [0, 2, 0],
        [1, 0, 0],
      ];
    case HammerType.xHammer:
      return [
        [1, 0, 1],
        [0, 2, 0],
        [1, 0, 1],
      ];
    case HammerType.positiveHammer:
      return [
        [0, 1, 0],
        [1, 2, 1],
        [0, 1, 0],
      ];
    case HammerType.smallSledgeHammer:
      return [
        [1, 1, 1],
        [1, 2, 1],
        [1, 1, 1],
      ];
    case HammerType.bigSledgeHammer:
      return [
        [1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1],
        [1, 1, 2, 1, 1],
        [1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1],
      ];
    case HammerType.rightDuo:
      return [
        [2, 1],
      ];
    case HammerType.downDuo:
      return [
        [2],
        [1],
      ];
    case HammerType.leftDuo:
      return [
        [1, 2],
      ];
    case HammerType.upDuo:
      return [
        [1],
        [2],
      ];
    case HammerType.fullRow:
      return [
        [9, 1, 2, 1, 9],
      ];
    case HammerType.fullColumn:
      return [
        [9],
        [1],
        [2],
        [1],
        [9],
      ];
    default:
      return [
        [2],
      ];
  }
}

class HammerPatternGrid extends StatelessWidget {
  final List<List<int>> pattern;
  final Color color;
  const HammerPatternGrid({
    required this.pattern,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final int rowCount = pattern.length;
    final int colCount = pattern[0].length;
    final double cellSize = MediaQuery.of(context).size.width * 0.08;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int r = 0; r < rowCount; r++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int c = 0; c < colCount; c++)
                Container(
                  width: cellSize,
                  height: cellSize,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: pattern[r][c] == 2
                        ? color.withValues(alpha: 0.85)
                        : pattern[r][c] == 1
                        ? color.withValues(alpha: 0.45)
                        : Colors.transparent,
                    border: Border.all(
                      color: pattern[r][c] == 0
                          ? Colors.grey.withValues(alpha: 0.25)
                          : color.withValues(alpha: 0.7),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: pattern[r][c] == 2
                      ? Center(
                          child: Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: cellSize * 0.5,
                          ),
                        )
                      : pattern[r][c] == 9
                      ? Center(
                          child: Icon(
                            Icons.all_inclusive,
                            color: Colors.black87.withValues(alpha: 0.8),
                            size: cellSize * 0.55,
                          ),
                        )
                      : null,
                ),
            ],
          ),
      ],
    );
  }
}

class _ModQuickButton extends StatefulWidget {
  final HammerType? hammerType;
  final IconData? icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;
  final String? tooltip;
  final bool bounceOnTap;
  final bool showIcon;

  const _ModQuickButton({
    this.hammerType,
    this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.color,
    this.tooltip,
    this.bounceOnTap = false,
    this.showIcon = true,
  });

  @override
  State<_ModQuickButton> createState() => _ModQuickButtonState();
}

class _ModQuickButtonState extends State<_ModQuickButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scale = widget.isActive ? 1.06 : 1.0;
  }

  @override
  void didUpdateWidget(covariant _ModQuickButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final double target = widget.isActive ? 1.06 : 1.0;
    if (_scale != target && !_controller.isAnimating) {
      setState(() {
        _scale = target;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.bounceOnTap) {
      setState(() {
        _scale = 1.25;
      });
      await Future.delayed(const Duration(milliseconds: 120));
      setState(() {
        _scale = widget.isActive ? 1.06 : 1.0;
      });
      await Future.delayed(const Duration(milliseconds: 60));
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    Widget iconWidget = const SizedBox.shrink();
    if (widget.showIcon) {
      if (widget.icon != null) {
        iconWidget = Icon(
          widget.icon,
          color: Colors.white,
          size: screenWidth * 0.07,
        );
      } else if (widget.hammerType == HammerType.none) {
        iconWidget = Icon(
          Icons.edit,
          color: Colors.white,
          size: screenWidth * 0.07,
        );
      } else if (widget.hammerType == HammerType.singleTile) {
        iconWidget = Icon(
          Icons.construction,
          color: Colors.white,
          size: screenWidth * 0.07,
        );
      } else if (widget.hammerType != null) {
        iconWidget = Icon(
          Icons.construction,
          color: Colors.white,
          size: screenWidth * 0.07,
        );
      }
    }

    final Widget button = AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTap: widget.bounceOnTap ? _handleTap : widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.025,
            vertical: screenHeight * 0.01,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.color.withValues(alpha: 0.85)
                : Colors.grey[800],
            borderRadius: BorderRadius.circular(10),
            border: widget.isActive
                ? Border.all(color: widget.color, width: 2)
                : null,
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget,
              if (widget.label.isNotEmpty) ...[
                SizedBox(height: screenHeight * 0.015),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.032,
                  ),
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    return widget.tooltip != null
        ? Tooltip(message: widget.tooltip!, child: button)
        : button;
  }
}

// Rarity sekme butonu widget'ı
class _RarityTabButton extends StatelessWidget {
  final HammerRarity rarity;
  final bool isSelected;
  final VoidCallback onTap;
  const _RarityTabButton({
    required this.rarity,
    required this.isSelected,
    required this.onTap,
  });

  IconData get rarityIcon {
    switch (rarity) {
      case HammerRarity.rare:
        return Icons.star;
      case HammerRarity.epic:
        return Icons.diamond;
      case HammerRarity.legendary:
        return Icons.emoji_events;
      case HammerRarity.mystic:
        return Icons.bolt;
      default:
        return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getRarityColor(rarity);
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: screenWidth * 0.125,
        height: screenHeight * 0.05,
        alignment: Alignment.center,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Icon(rarityIcon, color: color, size: screenWidth * 0.06),
      ),
    );
  }
}

// HammerInfo model ve merkezi çekiç özellikleri
class HammerInfo {
  final String label;
  final Color color;
  final Color borderColor;
  final HammerRarity rarity;
  const HammerInfo({
    required this.label,
    required this.color,
    required this.borderColor,
    required this.rarity,
  });
}

const Map<HammerType, HammerInfo> hammerInfoMap = {
  HammerType.singleTile: HammerInfo(
    label: 'Basit Çekiç',
    color: Colors.red,
    borderColor: Colors.red,
    rarity: HammerRarity.common,
  ),
  HammerType.horizontalTrio: HammerInfo(
    label: 'Yatay Çekiç',
    color: Colors.lightBlue,
    borderColor: Colors.lightBlue,
    rarity: HammerRarity.rare,
  ),
  HammerType.verticalTrio: HammerInfo(
    label: 'Dikey Çekiç',
    color: Colors.teal,
    borderColor: Colors.teal,
    rarity: HammerRarity.rare,
  ),
  HammerType.diagonalLeft: HammerInfo(
    label: 'Sola Eğik Çekiç',
    color: Colors.lightBlueAccent,
    borderColor: Colors.lightBlueAccent,
    rarity: HammerRarity.rare,
  ),
  HammerType.diagonalRight: HammerInfo(
    label: 'Sağa Eğik Çekiç',
    color: Colors.indigoAccent,
    borderColor: Colors.indigoAccent,
    rarity: HammerRarity.rare,
  ),
  HammerType.rightDuo: HammerInfo(
    label: 'Sağ Kırıcı',
    color: Colors.tealAccent,
    borderColor: Colors.tealAccent,
    rarity: HammerRarity.rare,
  ),
  HammerType.downDuo: HammerInfo(
    label: 'Aşağı Kırıcı',
    color: Colors.cyan,
    borderColor: Colors.cyan,
    rarity: HammerRarity.rare,
  ),
  HammerType.leftDuo: HammerInfo(
    label: 'Sol Kırıcı',
    color: Colors.greenAccent,
    borderColor: Colors.greenAccent,
    rarity: HammerRarity.rare,
  ),
  HammerType.upDuo: HammerInfo(
    label: 'Yukarı Kırıcı',
    color: Colors.lightGreen,
    borderColor: Colors.lightGreen,
    rarity: HammerRarity.rare,
  ),
  HammerType.xHammer: HammerInfo(
    label: 'X Çekici',
    color: Colors.cyanAccent,
    borderColor: Colors.cyanAccent,
    rarity: HammerRarity.epic,
  ),
  HammerType.positiveHammer: HammerInfo(
    label: 'Pozitif Çekiç',
    color: Colors.blueAccent,
    borderColor: Colors.blueAccent,
    rarity: HammerRarity.epic,
  ),
  HammerType.fullColumn: HammerInfo(
    label: 'Sütun Çekici',
    color: Colors.brown,
    borderColor: Colors.brown,
    rarity: HammerRarity.legendary,
  ),
  HammerType.fullRow: HammerInfo(
    label: 'Satır Çekici',
    color: Colors.deepOrangeAccent,
    borderColor: Colors.deepOrangeAccent,
    rarity: HammerRarity.legendary,
  ),
  HammerType.smallSledgeHammer: HammerInfo(
    label: 'Küçük Balyoz',
    color: Colors.redAccent,
    borderColor: Colors.redAccent,
    rarity: HammerRarity.legendary,
  ),
  HammerType.bigSledgeHammer: HammerInfo(
    label: 'Büyük Balyoz',
    color: Colors.purpleAccent,
    borderColor: Colors.purpleAccent,
    rarity: HammerRarity.mystic,
  ),
};
