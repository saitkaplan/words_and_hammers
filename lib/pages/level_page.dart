import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:words_and_hammers/pages/game_page.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  final ScrollController _scrollController = ScrollController();

  int earnedPoint = 0;
  late List<Offset> _buttonPositions;
  final double _buttonHeightMultiplier = 0.05;
  double _contentHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      }
    });
  }

  List<Widget> _buildButtonAndField(double width, double height) {
    // Buton Konumları (x, y)
    // En Üst Level 1, en alt ise son level.
    // Genişlik çarpanı 0.7'i geçmemeli!
    _buttonPositions = [
      Offset(width * 0.31, height * 0.05), // Eğitim 1
      Offset(width * 0.22, height * 0.15), // Eğitim 2
      Offset(width * 0.47, height * 0.25), // Eğitim 3
      Offset(width * 0.63, height * 0.35), // 1
      Offset(width * 0.46, height * 0.45), // 2
      Offset(width * 0.28, height * 0.55), // 3
      Offset(width * 0.42, height * 0.65), // 4
      Offset(width * 0.56, height * 0.75), // 5
      Offset(width * 0.34, height * 0.85), // 6
      Offset(width * 0.14, height * 0.95), // 7
      Offset(width * 0.24, height * 1.05), // 8
      Offset(width * 0.20, height * 1.15), // 9
      Offset(width * 0.30, height * 1.25), // 10
      Offset(width * 0.41, height * 1.35), // 11
      Offset(width * 0.19, height * 1.45), // 12
    ];

    if (_buttonPositions.isNotEmpty) {
      double lastButtonBottom =
          _buttonPositions.last.dy + (height * _buttonHeightMultiplier);
      _contentHeight = lastButtonBottom + (height * 0.1);
    } else {
      _contentHeight = height;
    }

    return List.generate(_buttonPositions.length, (index) {
      final levelNumber = index + 1;
      String buttonLabel;
      bool isTutorial = false;
      int? realLevelIndex;
      if (levelNumber <= 3) {
        buttonLabel = 'Eğitim $levelNumber';
        isTutorial = true;
      } else {
        realLevelIndex = levelNumber - 3;
        buttonLabel = 'Bölüm $realLevelIndex';
      }
      return Positioned(
        left: _buttonPositions[index].dx,
        top: _buttonPositions[index].dy,
        child: InkWell(
          onTap: () async {
            final result = await Navigator.of(context).push<int>(
              MaterialPageRoute(
                builder: (_) => isTutorial
                    ? GamePage(
                        level: levelNumber,
                        earnedPoint: earnedPoint,
                        tutorialLevel: true,
                        tutorialLevelIndex: levelNumber,
                      )
                    : GamePage(
                        level: realLevelIndex!,
                        earnedPoint: earnedPoint,
                      ),
              ),
            );
            if (result != null) {
              setState(() {
                earnedPoint = result;
              });
              if (kDebugMode) {
                print(
                  'BÖLÜM TAMAMLANDI VE SKOR DEĞERİ OLAN $earnedPoint SAYISI GÜNCELLENDİ!',
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            width: width * 0.25,
            height: height * 0.05,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                buttonLabel,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: width * 0.035,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    List<Widget> levelButtons = _buildButtonAndField(screenWidth, screenHeight);
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Colors.blueGrey.shade900,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width: screenWidth * 0.05),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.arrow_left_circle_fill,
                        size: screenWidth * 0.09,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      'Bölüm Seçimi',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(1),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Toplam Skor: $earnedPoint",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(1),
                    ),
                    SizedBox(width: screenWidth * 0.05),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: SizedBox(
                height: _contentHeight,
                child: Stack(children: levelButtons),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
