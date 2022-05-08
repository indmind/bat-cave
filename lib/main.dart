import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame_sandbox/ball.dart';
import 'package:flutter/material.dart';

import 'obstacle.dart';

double mapRange(double value, a, b, c, d) {
  value = (value - a) / (b - a);

  return c + value * (d - c);
}

void main() {
  runApp(
    MaterialApp(
      title: 'Bat Cave',
      home: SafeArea(
        child: LayoutBuilder(builder: (context, _) {
          return Stack(
            children: [
              GameWidget(game: MyGame()),
              IgnorePointer(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.6),
                        Colors.black
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  // color: Colors.black.withOpacity(0.1),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.1),
                        Colors.black
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    ),
  );
}

class MyGame extends FlameGame
    with HasCollisionDetection, FPSCounter, VerticalDragDetector {
  final _ball = Ball(20, Paint()..color = Colors.transparent);
  // ..debugMode = true;

  late final SpriteAnimationComponent player;

  late final TextComponent distranceTraveled;

  Vector2? target;
  bool onTarget = false;

  late Timer interval;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    Flame.device.fullScreen();
    Flame.device.setLandscape();

    final parallaxComponent = await loadParallaxComponent(
      [
        ParallaxImageData('background.jpg'),
      ],
      baseVelocity: Vector2(20, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.0),
    );

    add(parallaxComponent);

    children.register<Obstacle>();

    interval = Timer(
      1.5,
      onTick: () {
        // limit the number of obstacles in one screen only 10
        if (children.query<Obstacle>().length < 10) {
          add(Obstacle(
            initialX: canvasSize.x + 100,
            // random gap between 80 - 50% of canvaxSize.y
            gapSize:
                mapRange(Random().nextDouble(), 0, 1, 80, canvasSize.y * 0.5),
          ));
        }
      },
      repeat: true,
    );

    add(ScreenHitbox());
    add(_ball);

    final animation = await loadSpriteAnimation(
      'bat.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(32),
        stepTime: 0.15,
      ),
    );

    player = SpriteAnimationComponent(
      animation: animation,
      size: Vector2.all(80),
    );

    add(player);

    distranceTraveled = TextComponent(
      position: Vector2(40, 40),
      text: '0',
    );

    add(distranceTraveled);
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);

    if (target != null) {
      _ball.follow(target!, dt);
    }

    for (final obstacle in children.query<Obstacle>()) {
      if (obstacle.position.x < -obstacle.width) {
        obstacle.removeFromParent();
      }
    }

    player.position = _ball.position - player.size / 2;

    distranceTraveled.text = _ball.distanceTraveled.toStringAsFixed(1) + ' m';
  }

  @override
  Color backgroundColor() {
    return Colors.grey[850]!;
  }

  // @override
  // void onMouseMove(PointerHoverInfo info) {
  //   final position = info.eventPosition.game;

  //   // final mappedY =
  //   //     mapRange(position.y, 0, canvasSize.y, -100, canvasSize.y + 100);

  //   target = position;
  //   // final position = info.eventPosition.game;
  //   // final yTopBound = canvasSize.y - canvasSize.y * 0.2;
  //   // final yBottomBound = yTopBound + (canvasSize.y * 0.2) - 10;

  //   // if (position.y >= yTopBound && position.y <= yBottomBound) {
  //   //   print(yTopBound);
  //   //   target = Vector2(
  //   //     position.x,
  //   //     mapRange(position.y, yTopBound, yBottomBound, 0, canvasSize.y),
  //   //   );
  //   // }
  // }

  @override
  void onVerticalDragUpdate(DragUpdateInfo info) {
    final position = info.eventPosition.game;

    const yTopBound = 0;
    final yBottomBound = canvasSize.y;

    if (position.y >= yTopBound && position.y <= yBottomBound) {
      target = position;
    }
  }
}
