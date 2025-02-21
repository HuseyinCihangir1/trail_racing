import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Timer gameTimer;
  late DateTime startTime;
  double playerLeft = 150;
  double playerTop = 500;
  int score = 0;
  bool isGameRunning = false;
  List<Offset> fallingObjects = [];
  int dropDelay = 0;
  final Random random = Random();

  void startGame() {
    setState(() {
      isGameRunning = true;
      score = 0;
      fallingObjects.clear();
      dropDelay = 0;
      startTime = DateTime.now();
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      setState(() {
        for (int i = 0; i < fallingObjects.length; i++) {
          fallingObjects[i] = fallingObjects[i] + const Offset(0, 3);
        }

        fallingObjects.removeWhere((position) {
          if (position.dy > MediaQuery.of(context).size.height) {
            score++;
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
    double xPosition = random.nextDouble() * MediaQuery.of(context).size.width;
    fallingObjects.add(Offset(xPosition, -50));
  }

  void _checkCollisions() {
    for (Offset position in fallingObjects) {
      if ((position.dx - playerLeft).abs() < 30 &&
          (position.dy - playerTop).abs() < 30) {
        endGame();
      }
    }
  }

  void endGame() {
    setState(() {
      isGameRunning = false;
      gameTimer.cancel();
      score = _calculateScore();
    });
  }

  int _calculateScore() {
    int secondsSurvived = DateTime.now().difference(startTime).inSeconds;
    if (secondsSurvived < 60) return random.nextInt(9) + 1;
    if (secondsSurvived < 300) return random.nextInt(90) + 10;
    return random.nextInt(900) + 100;
  }

  void moveLeft() {
    setState(() {
      playerLeft = max(playerLeft - 10, 0);
    });
  }

  void moveRight() {
    setState(() {
      playerLeft = min(playerLeft + 10, MediaQuery.of(context).size.width - 50);
    });
  }

  void moveUp() {
    setState(() {
      playerTop = max(playerTop - 10, 0);
    });
  }

  void resetGame() {
    setState(() {
      score = 0;
      fallingObjects.clear();
      isGameRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black),
          ),
          Positioned(
            left: playerLeft,
            top: playerTop,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
          for (Offset position in fallingObjects)
            Positioned(
              left: position.dx,
              top: position.dy,
              child: Container(
                width: 10,
                height: 50,
                color: Colors.blue,
              ),
            ),
          if (!isGameRunning)
            Center(
              child: ElevatedButton(
                onPressed: startGame,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text("Start Game"),
              ),
            ),
          if (!isGameRunning && score > 0)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Score: $score",
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text("Try Again"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (gameTimer.isActive) gameTimer.cancel();
    super.dispose();
  }
}
