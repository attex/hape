import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'constants.dart';
import 'game-object.dart';
import 'sprite.dart';

Sprite ogSprite = Sprite()
  ..imagePath = "assets/images/og.png"
  ..imageWidth = 227
  ..imageHeight = 198;

class OG extends GameObject {
  final Offset worldLocation;

  OG({this.worldLocation});

  @override
  Rect getRect(Size screenSize, double runDistance) {
    return Rect.fromLTWH(
      (worldLocation.dx - runDistance) * WORLD_TO_PIXEL_RATIO / 2,
      screenSize.height / 2 - ogSprite.imageHeight - worldLocation.dy - 15,
      ogSprite.imageWidth.toDouble(),
      ogSprite.imageHeight.toDouble(),
    );
  }

  @override
  Widget render() {
    return Image.asset(ogSprite.imagePath);
  }
}
