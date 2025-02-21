import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Timer timer1;
  late Timer gameTimer;
  double myCarLeft = 150;
  double myCarTop = 600;
  int puan = 0;
  bool oyunDurumu = false;
  List<double> fallingObjectsLeft = [];
  List<double> fallingObjectsRight = [];
  int dropDelay = 0;
  int oyunSuresi = 0;
  Random random = Random();

  void baslat() {
    setState(() {
      oyunDurumu = true;
      dropDelay = 0;
      oyunSuresi = 0;
      puan = 0;
      fallingObjectsLeft.clear();
      fallingObjectsRight.clear();
    });

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (oyunDurumu) {
        setState(() {
          oyunSuresi++;
        });
      } else {
        timer.cancel();
      }
    });

    timer1 = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      setState(() {
        for (int i = 0; i < fallingObjectsLeft.length; i++) {
          fallingObjectsLeft[i] += 5;
        }
        for (int i = 0; i < fallingObjectsRight.length; i++) {
          fallingObjectsRight[i] += 5;
        }

        fallingObjectsLeft.removeWhere((position) {
          if (position > MediaQuery.of(context).size.height) {
            puan++;
            return true;
          }
          return false;
        });

        fallingObjectsRight.removeWhere((position) {
          if (position > MediaQuery.of(context).size.height) {
            puan++;
            return true;
          }
          return false;
        });

        if (dropDelay == 0) {
          _createFallingObject();
          dropDelay = random.nextInt(60) + 45;
        } else {
          dropDelay--;
        }

        _checkCollisions();
      });
    });
  }

  void _createFallingObject() {
    if (random.nextBool()) {
      fallingObjectsLeft.add(-30);
    } else {
      fallingObjectsRight.add(-30);
    }
  }

  void _checkCollisions() {
    for (double position in fallingObjectsLeft) {
      if (position >= myCarTop - 50 &&
          position <= myCarTop + 50 &&
          myCarLeft <= 140 + 50 &&
          myCarLeft >= 140) {
        oyunBitti();
      }
    }

    for (double position in fallingObjectsRight) {
      if (position >= myCarTop - 50 &&
          position <= myCarTop + 50 &&
          myCarLeft <= 220 + 50 &&
          myCarLeft >= 220) {
        oyunBitti();
      }
    }
  }

  void oyunBitti() {
    setState(() {
      oyunDurumu = false;
      timer1.cancel();
      gameTimer.cancel();
    });
  }

  void yenidenBaslat() {
    baslat();
  }

  void solYap() {
    setState(() {
      myCarLeft =
          (myCarLeft - 10).clamp(0, MediaQuery.of(context).size.width - 50);
    });
  }

  void sagYap() {
    setState(() {
      myCarLeft =
          (myCarLeft + 10).clamp(0, MediaQuery.of(context).size.width - 50);
    });
  }

  String getFormattedScore() {
    if (oyunSuresi < 60) {
      return puan.toString().padLeft(1, '0'); // Tek haneli skor
    } else if (oyunSuresi >= 60 && oyunSuresi < 300) {
      return puan.toString().padLeft(2, '0'); // İki haneli skor
    } else {
      return puan.toString().padLeft(3, '0'); // Üç haneli skor
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.grey),
          Positioned(
            left: myCarLeft,
            top: myCarTop,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          for (double position in fallingObjectsLeft)
            Positioned(
              top: position,
              left: 140,
              child: Container(
                width: 10,
                height: 50,
                color: Colors.blue,
              ),
            ),
          for (double position in fallingObjectsRight)
            Positioned(
              top: position,
              left: 220,
              child: Container(
                width: 10,
                height: 50,
                color: Colors.blue,
              ),
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Score: ${getFormattedScore()}',
                  style: const TextStyle(color: Colors.orange, fontSize: 30),
                ),
                Text(
                  'Time: ${oyunSuresi ~/ 60}:${(oyunSuresi % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          if (!oyunDurumu)
            Center(
              child: ElevatedButton(
                onPressed: baslat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  oyunSuresi > 0 ? "Try Again" : "Start",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
