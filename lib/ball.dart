import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_sandbox/main.dart';
import 'package:flame_sandbox/obstacle.dart';
import 'package:flutter/material.dart';

class Ball extends CircleComponent with HasGameRef, CollisionCallbacks {
  Ball(double radius, Paint paint)
      : super(
          radius: radius,
          paint: paint,
          anchor: Anchor.center,
        );

  double yvel = 0;

  double distanceTraveled = 0;

  @override
  Future<void>? onLoad() async {
    await add(CircleHitbox(radius: radius));
  }

  @override
  void onGameResize(Vector2 size) {
    position = Vector2(radius * 2 + 50, size.y / 2);
    super.onGameResize(size);
  }

  @override
  void update(double dt) {
    yvel += 15;
    yvel *= 0.98;
    position += Vector2(0, yvel * dt);

    //stop in ground
    if (position.y > gameRef.size.y - radius) {
      position.y = gameRef.size.y - radius;
      yvel = 0;
    }

    //top in ceiling
    if (position.y < radius) {
      position.y = radius;
      yvel = 0;
    }

    // add distance traveled
    distanceTraveled += 0.5 * dt;
    super.update(dt);
  }

  void follow(Vector2 target, double dt) {
    return;
    // position.moveToTarget(target..x = position.x, 50 * dt);
    final yDist = (target.y - position.y).abs();

    print(yDist.toStringAsFixed(1));

    // if the distance is far, lower the speed to counterpart the lerp effect
    final speed = mapRange(yDist, gameRef.canvasSize.y, 0, 0.5, 1.5);

    print(speed.toStringAsFixed(1));

    position.lerp(target..x = position.x, speed * dt);
    // position.lerp(target..x = position.x, 1.2 * dt);
    // Vector2 dir = (target - position);

    // dir.x = 600;

    // // if (dir.y.abs() < 150) {
    // dir.x =
    //     mapRange(dir.y.abs(), gameRef.canvasSize.y / 2, 0, dir.x, dir.x * 0.2);
    // // }

    // dir.normalize();
    // dir.x = 0;

    // position.add(dir * gameRef.size.y * 1.5 * dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Tube) {
      // other.setColor(Colors.red);

      if (!other.isCollided) {
        gameRef.camera.shake(
          duration: 0.3,
          intensity: 10,
        );

        // if (other.flipped) {
        //   // push player down
        //   position.y = other.size.y + radius * 2;
        // } else {
        //   // push player up
        //   position.y = gameRef.size.y - other.size.y - radius * 2;
        // }
      }

      other.isCollided = true;
    }

    super.onCollision(intersectionPoints, other);
  }

  void jump() {
    yvel += -800;

    yvel = yvel.clamp(-400, yvel.abs());
  }
}
