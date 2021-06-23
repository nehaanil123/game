import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:plants_vs_zombie/Constant/assets.dart';
import 'package:plants_vs_zombie/Models/bullet.dart';
import 'package:plants_vs_zombie/Models/main_handler.dart';
import 'package:plants_vs_zombie/Models/plant.dart';
import 'package:plants_vs_zombie/Models/monument.dart';
import 'package:plants_vs_zombie/Models/zombie.dart';
import 'package:plants_vs_zombie/Utils/audio_player.dart';
import 'package:plants_vs_zombie/Utils/math_util.dart';
import 'package:plants_vs_zombie/Widgets/bullet.dart';
import 'package:plants_vs_zombie/Widgets/cotrollers_button.dart';
import 'package:plants_vs_zombie/Widgets/plant.dart';
import 'package:plants_vs_zombie/Widgets/score_board.dart';
import 'package:plants_vs_zombie/Widgets/zombie.dart';
import 'package:plants_vs_zombie/routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MonumentHandler _monument = MonumentHandler(-0.80, 0.0);
  PlantHandler _plant = PlantHandler(-0.70, 0.2);
  Bullethandler _bullet = Bullethandler(5, 5);
  ZombieHandler _zombie = ZombieHandler(1.1, 1);
  Timer _zombieTimer, _bulletTimer;
  int score = 0;

  /// move the plant up Y↑
  _moveUp(MainHandler mock) {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (ControllerButton().isTapping()) {
        setState(() {
          mock.moveUp(-0.05);
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// move the plant Down Y↓
  _moveDown(MainHandler mock) {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (ControllerButton().isTapping()) {
        setState(() {
          mock.moveDown(0.05);
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// shooting the bullets
  _shootBullet() async {
    if (_bullet.x == 5) {
      await AudioPlayer.playSound(Assets.shootSoundEffet);
      setState(() {
        _bullet.initCords(_plant.x, _plant.y);
      });
      _bulletTimer = Timer.periodic(Duration(milliseconds: 10), (timer) {
        setState(() {
          _bullet.moveRight();
        });
        if ((_bullet.x - _zombie.x).abs() < 0.05 &&
            (_bullet.y - _zombie.y).abs() < 0.2) {
          timer.cancel();
          if (_zombieTimer != null) {
            _zombieTimer.cancel();
          }
          _bullet.initCords(5, 5);
          _calculateScore();
          _moveZombie();
        }
        if (_bullet.x > 1.3) {
          timer.cancel();
          _bullet.initCords(5, 5);
        }
      });
    }
  }

  /// moving the zombie
  _moveZombie() {
    setState(() {
      _zombie.initCords(1.1, nexRandom(-0.9, 0.9));
    });
    if (_zombie.x == 1.1) {
      _zombieTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
        setState(() {
          _zombie.moveLeft();
        });
        if ((_plant.x - _zombie.x).abs() < 0.05) {
          timer.cancel();
          if (_bulletTimer != null) {
            _bulletTimer.cancel();
          }
          print("Game Over");
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.game_over, (route) => false,
              arguments: score);
        }
      });
    }
  }

  _calculateScore() {
    setState(() {
      score++;
    });
  }

  @override
  void initState() {
    super.initState();
    _moveZombie();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              _garden(),
              _gameControllers(),
              _text(),
            ],
          ),
        ),
      ),
    );
  }

  /// Game controllers arrows & shoot button
  Widget _gameControllers() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.brown[600],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                ControllerButton(
                    icon: Icons.arrow_upward,
                    onTap: () {
                      _moveUp(_plant);
                    }),
                SizedBox(width: 15.0),
                ControllerButton(
                  icon: Icons.arrow_downward,
                  onTap: () {
                    _moveDown(_plant);
                  },
                ),
              ],
            ),
            ScoreBoard(
              score: score,
            ),
            ControllerButton(
              icon: FontAwesomeIcons.meteor,
              onTap: _shootBullet,
            ),
          ],
        ),
      ),
    );
  }

  /// the main garden
  _garden() {
    return Expanded(
      flex: 5,
      child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.garden),
              fit: BoxFit.cover,
            ),
          ),
          child: _players()),
    );
  }
  ///text displaying
  _text(){
    return Container(
      height: 100,
      color: Colors.white,
      child: AnimatedTextKit(
        animatedTexts: [
          WavyAnimatedText('Taj Mahal', textStyle: TextStyle(fontSize:40,color:Colors.green)),
          ColorizeAnimatedText(' Built by a whopping 22,000 laborers, painters, stonecutters, embroidery artists.', textStyle: TextStyle(fontSize:30,color:Colors.green),colors: [Colors.amber,Colors.green,Colors.yellow,Colors.orange,Colors.blue]),
          ColorizeAnimatedText(' It intricate work of art and architectural genius took 17 years to complete.', textStyle: TextStyle(fontSize:30,color:Colors.green),colors: [Colors.amber,Colors.green,Colors.yellow,Colors.orange,Colors.blue]),
          ColorizeAnimatedText(' The materials that were used to build Taj Mahal were transported to the construction site by a whopping 1,000 elephants.', textStyle: TextStyle(fontSize:30,color:Colors.green),colors: [Colors.amber,Colors.green,Colors.yellow,Colors.orange,Colors.blue]),
          ColorizeAnimatedText(' Taj Mahal is a famous Indian landmark and tourist magnet, attracting more than a million tourists every year.', textStyle: TextStyle(fontSize:30,color:Colors.green),colors: [Colors.amber,Colors.green,Colors.yellow,Colors.orange,Colors.blue]),
          ColorizeAnimatedText(' Taj Mahal is indeed a beautiful place', textStyle: TextStyle(fontSize:30,color:Colors.green),colors: [Colors.amber,Colors.green,Colors.yellow,Colors.orange,Colors.blue]),
          
        ],

      )

    );

  }

  /// Plants , Zombies & bullet will be displayed
  Widget _players() {
    return Stack(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 0),
          alignment: Alignment(_plant.x, _plant.y),
          child: Plant(),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 0),
          alignment: Alignment(_bullet.x, _bullet.y),
          child: Bullet(),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 0),
          alignment: Alignment(_zombie.x, _zombie.y),
          child: Zombie(),
        ),
        Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.monumentMock),
              alignment: Alignment(_monument.x, _monument.y),
              scale: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}
