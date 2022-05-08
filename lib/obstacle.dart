import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Obstacle extends PositionComponent with HasGameRef {
  final double gapSize;
  final double initialX;

  late final int topHeight;
  late final int bottomHeight;

  Obstacle({
    required this.initialX,
    required this.gapSize,
  }) : super(
          anchor: Anchor.center,
          position: Vector2(initialX, 0),
        ) {
    // set width to random between 100 and 200
    width = Random().nextDouble() * 100 + 100;
  }

  final speed = 200;

  Tube? topTube;
  Tube? bottomTube;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    // debugMode = true;

    // final color = Color.fromRGBO(
    //   Random().nextInt(255),
    //   Random().nextInt(255),
    //   Random().nextInt(255),
    //   1,
    // );

    const color = Colors.transparent;

    topHeight = max(
      (gameRef.size.y * 0.2).toInt(),
      Random().nextInt(
        max(
          100,
          gameRef.size.y.toInt() - gapSize.toInt(),
        ),
      ),
    );

    bottomHeight = (gameRef.size.y - topHeight - gapSize).toInt();
    // bottomHeight = 100;

    final xpos = <double>[0, width - 100]..shuffle();

    topTube = Tube(
      Vector2(100, topHeight.toDouble()),
      Vector2(xpos[0], 100),
      color,
      Anchor.topCenter,
      true,
    );
    bottomTube = Tube(
      Vector2(100, bottomHeight.toDouble()),
      Vector2(xpos[1], size.y),
      color,
      Anchor.bottomCenter,
      false,
    );

    // to make sure the tubes are passable
    if (gapSize < 100) {
      topTube?.position.x -= 50;
      bottomTube?.position.x += 50;
    }

    add(topTube!);
    add(bottomTube!);
  }

  @override
  void onGameResize(Vector2 size) {
    topTube?.position.y = 0;
    bottomTube?.position.y = size.y;
    super.onGameResize(size);
  }

  @override
  void update(double dt) {
    position.x -= speed * dt;

    topTube?.position.y = 0;
    bottomTube?.position.y = gameRef.canvasSize.y;

    // if (position.x < -100) {
    //   position.x = gameRef.canvasSize.x;
    // }
  }
}

class Tube extends RectangleComponent {
  final bool flipped;
  Tube(
    Vector2 size,
    Vector2 position,
    Color color,
    Anchor anchor,
    this.flipped,
  ) : super(
          size: size,
          position: position,
          paint: Paint()..color = color,
          anchor: anchor,
        );

  bool isCollided = false;

  @override
  Future<void>? onLoad() async {
    final sprite = await Sprite.load('rock.png');
    final rock = SpriteComponent(
      size: size,
      position: size / 2,
      anchor: Anchor.center,
      sprite: sprite,
    );

    if (flipped) {
      rock.angle = pi;
    }

    add(rock);

    // add(RectangleHitbox(
    //   size: size,
    if (!flipped) {
      add(PolygonHitbox([
        Vector2(size.x, size.y),
        Vector2(0, size.y),
        Vector2(size.x * 0.4, 0),
        Vector2(size.x * 0.4 + 20, 0),
      ]));
    } else {
      add(PolygonHitbox([
        Vector2(0, 0),
        Vector2(size.x, 0),
        Vector2(size.x * 0.6, size.y),
        Vector2(size.x * 0.6 - 20, size.y),
      ]));
    }
  }
}
