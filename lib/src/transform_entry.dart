import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Functional equivalent of [RSTransform] in [Matrix4] world,
/// check [RSTransform.fromComponents] for more info about the parameters.

Matrix4 composeMatrix({
  double scale = 1,
  double rotation = 0,
  double? translateX,
  double? translateY,
  Offset? translate,
  double? anchorX,
  double? anchorY,
  Offset? anchor,
}) {
  assert(translate == null || translateX == null, 'cannot provide both translate and translateX');
  assert(translate == null || translateY == null, 'cannot provide both translate and translateY');
  final tx = translateX ?? translate?.dx ?? 0;
  final ty = translateY ?? translate?.dy ?? 0;
  assert(anchor == null || anchorX == null, 'cannot provide both anchor and anchorX');
  assert(anchor == null || anchorY == null, 'cannot provide both anchor and anchorY');
  final ax = anchorX ?? anchor?.dx ?? 0;
  final ay = anchorY ?? anchor?.dy ?? 0;

  final double c = cos(rotation) * scale;
  final double s = sin(rotation) * scale;
  final double dx = tx - c * ax + s * ay;
  final double dy = ty - s * ax - c * ay;

  //  ..[0]  = c       # x scale
  //  ..[1]  = s       # y skew
  //  ..[4]  = -s      # x skew
  //  ..[5]  = c       # y scale
  //  ..[10] = 1       # diagonal "one"
  //  ..[12] = dx      # x translation
  //  ..[13] = dy      # y translation
  //  ..[15] = 1       # diagonal "one"
  return Matrix4(c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, dx, dy, 0, 1);
}

class TransformEntry with Diagnosticable {
  /// The scale factor.
  final double scale;

  /// The rotation in radians.
  final double rotation;

  /// The x coordinate of the offset by which to translate the anchor point.
  final double translateX;

  /// The y coordinate of the offset by which to translate the anchor point.
  final double translateY;

  /// The x coordinate of the point around which to scale and rotate.
  final double anchorX;

  /// The y coordinate of the point around which to scale and rotate.
  final double anchorY;

  TransformEntry({
    this.scale = 1,
    this.rotation = 0,
    double? translateX,
    double? translateY,
    Offset? translate,
    double? anchorX,
    double? anchorY,
    Offset? anchor,
  }) :
    assert(translate == null || translateX == null, 'cannot provide both translate and translateX'),
    assert(translate == null || translateY == null, 'cannot provide both translate and translateY'),
    translateX = translateX ?? translate?.dx ?? 0,
    translateY = translateY ?? translate?.dy ?? 0,
    assert(anchor == null || anchorX == null, 'cannot provide both anchor and anchorX'),
    assert(anchor == null || anchorY == null, 'cannot provide both anchor and anchorY'),
    anchorX = anchorX ?? anchor?.dx ?? 0,
    anchorY = anchorY ?? anchor?.dy ?? 0;

  Matrix4 get matrix => composeMatrix(
      scale: scale,
      rotation: rotation,
      translateX: translateX,
      translateY: translateY,
      anchorX: anchorX,
      anchorY: anchorY,
    );

  TransformEntry updateBy({
    double? scale,
    double? rotation,
    double? translateX,
    double? translateY,
    double? anchorX,
    double? anchorY,
  }) => TransformEntry(
    scale: scale == null? this.scale : this.scale * scale,
    rotation: rotation == null? this.rotation : this.rotation + rotation,
    translateX: translateX == null? this.translateX : this.translateX + translateX,
    translateY: translateY == null? this.translateY : this.translateY + translateY,
    anchorX: anchorX == null? this.anchorX : this.anchorX + anchorX,
    anchorY: anchorY == null? this.anchorY : this.anchorY + anchorY,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('scale', scale));
    properties.add(DoubleProperty('rotation', rotation));
    properties.add(DoubleProperty('translateX', translateX));
    properties.add(DoubleProperty('translateY', translateY));
    properties.add(DoubleProperty('anchorX', anchorX));
    properties.add(DoubleProperty('anchorY', anchorY));
  }
}

class TransformEntryTween extends Tween<TransformEntry> {
  TransformEntryTween({
    TransformEntry? begin,
    TransformEntry? end
  }) : super(begin: begin, end: end);

  @override
  TransformEntry lerp(double t) => TransformEntry(
    scale: lerpDouble(begin?.scale, end?.scale, t) ?? 1,
    rotation: lerpDouble(begin?.rotation, end?.rotation, t) ?? 0,
    translateX: lerpDouble(begin?.translateX, end?.translateX, t) ?? 0,
    translateY: lerpDouble(begin?.translateY, end?.translateY, t) ?? 0,
    anchorX: lerpDouble(begin?.anchorX, end?.anchorX, t) ?? 0,
    anchorY: lerpDouble(begin?.anchorY, end?.anchorY, t) ?? 0,
  );
}

extension CanvasTransformExtension on Canvas {
  ({Matrix4 computed, Matrix4 effective}) transformMatrix({
    double scale = 1,
    double rotation = 0,
    Offset translate = Offset.zero,
    Offset anchor = Offset.zero,
    bool fillEffectiveMatrix = false,
  }) {
    final matrix = composeMatrix(
      scale: scale,
      rotation: rotation,
      translate: translate,
      anchor: anchor,
    );
    transform(matrix.storage);
    return (
      computed: matrix,
      effective: fillEffectiveMatrix? Matrix4.fromList(getTransform()) : Matrix4.zero(),
    );
  }
}
