// ignore_for_file: curly_braces_in_flow_control_structures

/*
 * Copyright 2019 by Marcelo Glasberg
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted
 * provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions
 * and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other materials provided
 * with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import 'dart:math' as math show cos, pi, Point, sin;

import 'package:meta/meta.dart' show immutable;
import 'package:vector_math/vector_math.dart' show Matrix4;

// Developed by Marcelo Glasberg (Aug 2019).
// For more info, see: https://pub.dev/packages/matrix4_transform

@immutable
class Matrix4Transform {
  final Matrix4 m;

  Matrix4Transform() : m = Matrix4.identity();

  Matrix4Transform.from(Matrix4 m) : m = m.clone();

  Matrix4Transform._(this.m);

  Matrix4 get matrix4 => m.clone();

  /// Rotates by [angleRadians] radians, clockwise.
  /// If you define an origin it will have that point as the axis of rotation.
  Matrix4Transform rotate(double angleRadians, {math.Point<double>? origin}) {
    if (angleRadians == 0.0)
      return this;
    else if ((origin == null) || (origin.x == 0.0 && origin.y == 0.0))
      return Matrix4Transform._(m.clone()..rotateZ(angleRadians));
    else
      return Matrix4Transform._(
        m.clone()
          ..translate(origin.x, origin.y)
          ..multiply(Matrix4.rotationZ(angleRadians))
          ..translate(-origin.x, -origin.y),
      );
  }

  /// Rotates by [angleDegrees] degrees (0 to 360 one turn), clockwise.
  /// If you define an origin it will have that point as the axis of rotation.
  Matrix4Transform rotateDegrees(double angleDegrees,
          {math.Point<double>? origin}) =>
      rotate(_toRadians(angleDegrees), origin: origin);

  /// Rotates by [angleDegrees] degrees (0 to 360 one turn), clockwise.
  /// The axis of rotation will be the center of the object with the given size.
  Matrix4Transform rotateByCenterDegrees(
          double angleDegrees, double width, double height) =>
      rotateByCenter(_toRadians(angleDegrees), width, height);

  /// Rotates by [angleRadians] radians, clockwise.
  /// The axis of rotation will be the center of the object with the given size.
  Matrix4Transform rotateByCenter(
          double angleRadians, double width, double height) =>
      rotate(
        angleRadians,
        origin: math.Point(width / 2, height / 2),
      );

  /// Translates by [x] pixels (horizontal) and [y] pixels (vertical).
  /// Positive goes down/right.
  ///
  Matrix4Transform translate({double x = 0, double y = 0}) {
    return (x == 0 && y == 0) //
        ? this
        : Matrix4Transform._(m.clone()..leftTranslate(x, y));
  }

  /// Translates by [x] pixels (horizontal) and [y] pixels (vertical), but in
  /// respect to the original coordinate system, before the translates/scales.
  ///
  /// Example: If you rotate 30 degrees, and then call this method to translate
  /// x:10 it will translate by a distance of 10 pixels in 30 degrees.
  ///
  /// Example: If you resize by 1.5, and then call this method to translate
  /// x:10 it will translate by 15 pixels.
  ///
  Matrix4Transform translateOriginalCoordinates({double x = 0, double y = 0}) =>
      (x == 0 && y == 0) //
          ? this
          : Matrix4Transform._(m.clone()..translate(x, y));

  /// Scales by [factor], keeping the aspect ratio.
  /// Gets bigger for >1.
  /// Smaller for <1.
  /// Same size for 1 (and passing null is the same as passing 1).
  /// No size for 0.
  /// Passing null is the same as passing 1.
  Matrix4Transform scale(double factor, {math.Point<double>? origin}) =>
      scaleBy(x: factor, y: factor, origin: origin);

  /// Scales by a factor of [x] (horizontal) and [y] (vertical).
  /// Gets bigger for >1.
  /// Smaller for <1.
  /// Same size for 1 (and passing null is the same as passing 1).
  /// No size for 0.
  Matrix4Transform scaleBy(
      {double x = 1, double y = 1, math.Point<double>? origin}) {
    if (x == 1 && y == 1)
      return this;
    else if ((origin == null) || (origin.x == 0.0 && origin.y == 0.0))
      return Matrix4Transform._(
        m.clone()..multiply(Matrix4.identity()..scale(x, y)),
      );
    else
      return Matrix4Transform._(
        m.clone()
          ..translate(origin.x, origin.y)
          ..multiply(Matrix4.identity()..scale(x, y))
          ..translate(-origin.x, -origin.y),
      );
  }

  /// Scales by [factor] horizontally. Keeps the same vertical scale.
  /// Gets bigger for >1.
  /// Smaller for <1.
  /// Same size for 1 (and passing null is the same as passing 1).
  /// No size for 0.
  Matrix4Transform scaleHorizontally(double factor,
          {math.Point<double>? origin}) =>
      scaleBy(x: factor, origin: origin);

  /// Scales by [factor] vertically. Keeps the same horizontal scale.
  /// Gets bigger for >1.
  /// Smaller for <1.
  /// Same size for 1 (and passing null is the same as passing 1).
  /// No size for 0.
  Matrix4Transform scaleVertically(double factor,
          {math.Point<double>? origin}) =>
      scaleBy(y: factor, origin: origin);

  /// Translates by [x] pixels (horizontal) and [y] pixels (vertical).
  /// Positive goes down/right.
  Matrix4Transform translateOffset(math.Point<double> offset) =>
      Matrix4Transform._(m.clone()..translate(offset.x, offset.y));

  /// Translates up by [distance] pixels.
  Matrix4Transform up(double distance) => translate(y: -distance);

  /// Translates down by [distance] pixels.
  Matrix4Transform down(double distance) => translate(y: distance);

  /// Translates right by [distance] pixels.
  Matrix4Transform right(double distance) => translate(x: distance);

  /// Translates up left [distance] pixels.
  Matrix4Transform left(double distance) => translate(x: -distance);

  /// Translates by [distance] pixels to the [direction].
  /// The direction is in radians clockwise from the positive x-axis.
  Matrix4Transform direction(double directionRadians, double distance) =>
      translateOffset(
        math.Point(
          distance * math.cos(directionRadians),
          distance * math.sin(directionRadians),
        ),
      );

  /// Translates by [distance] pixels to the [direction].
  /// The direction is in degrees (0 to 360 one turn) clockwise
  /// from the positive x-axis.
  Matrix4Transform directionDegrees(
    double directionDegrees,
    double distance,
  ) {
    final directionRadians = _toRadians(directionDegrees);
    return translateOffset(
      math.Point(
        distance * math.cos(directionRadians),
        distance * math.sin(directionRadians),
      ),
    );
  }

  /// Translates up and right by [distance] pixels of distance.
  Matrix4Transform upRight(double distance) => //
      direction(-math.pi / 4, distance);

  /// Translates up and left [distance] pixels.
  Matrix4Transform upLeft(double distance) => //
      direction(-math.pi * 3 / 4, distance);

  /// Translates down and right by [distance] pixels.
  Matrix4Transform downRight(double distance) => //
      direction(math.pi / 4, distance);

  /// Translates down and left by [distance] pixels.
  Matrix4Transform downLeft(double distance) => //
      direction(math.pi * 3 / 4, distance);

  Matrix4Transform flipDiagonally({math.Point<double>? origin}) => //
      _flipDegrees(horizontal: 180, vertical: 180, origin: origin);

  Matrix4Transform flipHorizontally({math.Point<double>? origin}) => //
      _flipDegrees(horizontal: 180, origin: origin);

  Matrix4Transform flipVertically({math.Point<double>? origin}) => //
      _flipDegrees(vertical: 180, origin: origin);

  Matrix4Transform _flip({
    double horizontal = 0.0,
    double vertical = 0.0,
    math.Point<double>? origin,
  }) {
    if ((horizontal == 0.0) && (vertical == 0.0))
      return this;
    else if ((origin == null) || (origin.x == 0.0 && origin.y == 0.0))
      return Matrix4Transform._(
        m.clone()
          ..rotateY(horizontal)
          ..rotateX(vertical),
      );
    else
      return Matrix4Transform._(
        m.clone()
          ..translate(origin.x, origin.y)
          ..multiply(Matrix4.rotationY(horizontal))
          ..multiply(Matrix4.rotationX(vertical))
          ..translate(-origin.x, -origin.y),
      );
  }

  /// Flips (with perspective) horizontally and vertically by [distance] pixels.
  Matrix4Transform _flipDegrees({
    double horizontal = 0.0,
    double vertical = 0.0,
    math.Point<double>? origin,
  }) {
    return _flip(
      horizontal: _toRadians(horizontal),
      vertical: _toRadians(vertical),
      origin: origin,
    );
  }

  double _toRadians(double angleDegrees) => angleDegrees * math.pi / 180;
}
