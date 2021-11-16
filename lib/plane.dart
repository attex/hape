import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'game-object.dart';
import 'sprite.dart';

Sprite planeSprite = Sprite()
  ..imagePath = "assets/images/plane.png"
  ..imageWidth = 177
  ..imageHeight = 55;

class Plane extends GameObject {
  final Offset worldLocation;

  Plane({this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * WORLD_TO_PIXEL_RATIO / 3,
      screenSize.height / 4 - planeSprite.imageHeight - worldLocation.dy,
      planeSprite.imageWidth.toDouble(),
      planeSprite.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(planeSprite.imagePath);
  }
}
