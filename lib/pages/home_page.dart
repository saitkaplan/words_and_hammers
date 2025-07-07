import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:words_and_hammers/pages/level_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    // Durum çubuğunu verilerinin güncellenmesi ve Ana sayfanın başlatılması
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: screenHeight * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/logos/wnh_logo.png",
                      width: screenWidth * 0.5,
                    ),
                  ],
                ),
              ],
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const LevelPage()));
                },
                child: Text(
                  "Oyuna Başla",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Prototip 2 (Ver: 1.0.0)",
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.blueGrey.shade200,
                ),
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
