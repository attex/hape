import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'cactus.dart';
import 'constants.dart';
import 'game-object.dart';
import 'sprite.dart';

List<Sprite> dino = [
  Sprite()
    ..imagePath = "assets/images/dino/car_1.png"
    ..imageWidth = 113
    ..imageHeight = 43,
  Sprite()
    ..imagePath = "assets/images/dino/car_2.png"
    ..imageWidth = 113
    ..imageHeight = 43,
  Sprite()
    ..imagePath = "assets/images/dino/car_3.png"
    ..imageWidth = 113
    ..imageHeight = 43,
  Sprite()
    ..imagePath = "assets/images/dino/car_4.png"
    ..imageWidth = 113
    ..imageHeight = 43,
  Sprite()
    ..imagePath = "assets/images/dino/car_5.png"
    ..imageWidth = 113
    ..imageHeight = 43,
  Sprite()
    ..imagePath = "assets/images/dino/car_6.png"
    ..imageWidth = 113
    ..imageHeight = 43,
];

enum DinoState {
  ready,
  jumping,
  running,
  dead,
}

class Dino extends GameObject {
  Sprite currentSprite = dino[0];
  double dispY = 0;
  double velY = 0;
  DinoState state = DinoState.ready;

  @override
  Widget render() {
    return Image.asset(currentSprite.imagePath);
  }

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      screenSize.width / 10,
      screenSize.height / 2 - currentSprite.imageHeight - dispY,
      currentSprite.imageWidth.toDouble(),
      currentSprite.imageHeight.toDouble(),
    );
  }

  bool isDead() {
    return state == DinoState.dead;
  }
   bool isReady() {
    return state == DinoState.ready;
  }

  void run() {
     state = DinoState.running;
  }


  @override
  void update(Duration lastTime, Duration currentTime) {
    currentSprite = dino[(currentTime.inMilliseconds / 100).floor() % 2 + 2];

    double elapsedTimeSeconds = (currentTime - lastTime).inMilliseconds / 1000;

    dispY += velY * elapsedTimeSeconds;
    if (dispY <= 0) {
      dispY = 0;
      velY = 0;
      state = DinoState.running;
    } else {
      velY -= GRAVITY_PPSS * elapsedTimeSeconds;
    }
  }

  void jump() {
    if (state != DinoState.jumping) {
      state = DinoState.jumping;
      velY = 750;
    }
  }

  void die() {
    currentSprite = dino[5];
    state = DinoState.dead;
  }
}
