import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: Main(),
    theme: ThemeData.dark(),
  ));
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  double posY = 0;
  double posX = 0;
  double gravity = 12; //Decrease this value to make the game easier
  int score = 0;
  double jump = 400;
  bool isBallVisible = true;
  bool isPlaying = false;
  late double height;
  late double width;
  late int best;
  late SharedPreferences pref;
  late Timer time;

  @override
  void initState() {
    super.initState();
    _getBest();
    time = Timer.periodic(const Duration(milliseconds: 20), (Timer t) {
      _putBest(score);
      setState(() {
        if (isPlaying) {
          if (posY + 500 >= height) {
            isPlaying = false;
            isBallVisible = false;
          } else {
            posY = posY + gravity;
          }
          if (posX - 75 <= -width / 2) {
            posX = posX + 100;
          }
          if (posX + 75 >= width / 2) {
            posX = posX - 100;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            height: height,
            width: width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/1.jpg'), fit: BoxFit.fill)),
          ),
          AnimatedContainer(
            duration: const Duration(seconds: 1),
          ),
          (!isBallVisible | isPlaying)
              ? const SizedBox(
                  height: 0,
                  width: 0,
                )
              : const Center(
                  child: Positioned(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 270,
                      ),
                      Text(
                        'Tap the ball!',
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    ],
                  ),
                )),
          isBallVisible
              ? Container(
                  alignment: Alignment.topCenter,
                  margin: const EdgeInsets.only(top: 200),
                  child: Text(
                    '$score',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : const SizedBox(
                  width: 0,
                  height: 0,
                ),
          Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                width: 150,
                height: 150,
                transform: Matrix4.translationValues(posX, posY, 0),
                duration: const Duration(milliseconds: 100),
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: ExactAssetImage('assets/football.png')),
                          shape: BoxShape.circle),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            //left
                            setState(() {
                              score = score + 1;
                              if (!isPlaying) {
                                isPlaying = true;
                              }
                              posX = posX - 100;
                              posY = posY - jump;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        )),
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            //right
                            setState(() {
                              score = score + 1;
                              if (!isPlaying) {
                                isPlaying = true;
                              }
                              posX = posX + 100;
                              posY = posY - jump;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        )),
                      ],
                    )
                  ],
                ),
              )),
          isBallVisible
              ? const SizedBox(
                  width: 0,
                  height: 0,
                )
              : Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isBallVisible = true;
                        isPlaying = false;
                        posY = 0;
                        posX = 0;
                        score = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Best: $best',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.refresh, color: Colors.white, size: 50)
                      ],
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Future<int> _getBest() async {
    pref = await SharedPreferences.getInstance();
    best = pref.getInt('BEST') ?? 0;
    return best;
  }

  _putBest(int b) async {
    pref = await SharedPreferences.getInstance();
    int a = await _getBest();
    if (b > a) {
      pref.setInt('BEST', b);
    }
  }
}
