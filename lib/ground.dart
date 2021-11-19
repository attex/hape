import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'game-object.dart';
import 'sprite.dart';

Sprite groundSprite = Sprite()
  ..imagePath = "assets/images/ground.png"
  ..imageWidth = 2399
  ..imageHeight = 24;

class Ground extends GameObject {
  final Offset worldLocation;

  Ground({this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * WORLD_TO_PIXEL_RATIO / 1,//0.8, //getSpeed(runDistance),
      screenSize.height / 2 - groundSprite.imageHeight,
      groundSprite.imageWidth.toDouble(),
      groundSprite.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(groundSprite.imagePath);
  }

  double getSpeed(double distance) {
    if(distance < 500) {
      return 1.2;
    } else if(distance < 1500) {
      return 1.0;
    } else if(distance < 2500) {
      return 0.9;
    } else {
      return 0.8;
    }
  }
}
