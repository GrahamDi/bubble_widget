library bubble_widget;

import 'dart:math';

import 'package:flutter/material.dart';

/// Bubble component
///
/// @author Peter
///
/// Create on 2020/09/01
class BubbleWidget extends StatelessWidget {
  final Widget child;

  /// childCompared to bubbles padding
  final EdgeInsetsGeometry? padding;

  /// Bubble style， [BubbleStyle.stroke] For the sketch； [BubbleStyle.fill]For filling
  final BubbleStyle style;

  /// Background
  final Color color;

  /// Sketch color，[style] for [BubbleStyle.stroke] Time -effective
  final Color strokeColor;

  /// Sketch width，[style] for [BubbleStyle.stroke] Time -effective
  final double strokeWidth;

  /// Bubble Body rounded corner radius
  final double borderRadius;

  /// Bubble sharp corner width at the bottom of the corner
  final double arrowWidth;

  /// Bubble sharp corner height
  final double arrowHeight;

  /// The position of the foam tip of the bubble is relative to the bubble body
  final ArrowDirection direction;

  /// Bubble sharp corner relative position coefficient，0.0~1.0，Starting from
  /// the upper left corner
  final double positionRatio;

  /// @see [Material]of[elevation]Definition, Z axis height </br>
  /// The z-coordinate at which to place this material relative to its parent.
  final double? elevation;

  const BubbleWidget(
      {Key? key,
      required this.child,
      this.padding,
      this.color = Colors.transparent,
      this.arrowWidth = 8.0,
      this.arrowHeight = 5.0,
      this.borderRadius = 10.0,
      this.direction = ArrowDirection.bottom,
      this.positionRatio = 0.5,
      this.style = BubbleStyle.fill,
      this.strokeColor = Colors.transparent,
      this.strokeWidth = 0.5,
      this.elevation})
      : super(key: key);

  get _arrowMargin {
    var edgeInsets;
    switch (direction) {
      case ArrowDirection.left:
        edgeInsets = EdgeInsets.only(left: arrowHeight);
        break;
      case ArrowDirection.top:
        edgeInsets = EdgeInsets.only(top: arrowHeight);
        break;
      case ArrowDirection.right:
        edgeInsets = EdgeInsets.only(right: arrowHeight);
        break;
      default:
        edgeInsets = EdgeInsets.only(bottom: arrowHeight);
        break;
    }
    return edgeInsets;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: color,
        // When a transparent filling background, no projection is required
        shadowColor: color == Colors.transparent
            ? Colors.transparent
            : const Color(0xFF000000),
        elevation: elevation ?? (color == Colors.transparent ? 0 : 5),
        shape: BubbleShape(
            style: style,
            strokeColor: strokeColor,
            strokeWidth: strokeWidth,
            direction: direction,
            positionRatio: positionRatio,
            arrowHeight: arrowHeight,
            arrowWidth: arrowWidth,
            borderRadius: borderRadius),
        child: Container(margin: _arrowMargin, padding: padding, child: child));
  }
}

enum ArrowDirection { left, top, right, bottom }

enum BubbleStyle { stroke, fill }

/// Reference：https://juejin.im/post/6844904082629459982
class BubbleShape extends ShapeBorder {
  final BubbleStyle style;
  final Color strokeColor;
  final double strokeWidth;

  final ArrowDirection? direction;

  /// Bubble sharp corner height
  final double arrowHeight;

  /// Bubble sharp corner width (size at the bottom of the sharp corner)
  final double arrowWidth;

  /// Bubble round corner radius
  final double borderRadius;
  final double positionRatio;

  BubbleShape(
      {this.style = BubbleStyle.fill,
      this.strokeColor = Colors.transparent,
      this.strokeWidth = 0.5,
      this.direction = ArrowDirection.bottom,
      this.positionRatio = 0.5,
      this.arrowHeight = 5.0,
      this.arrowWidth = 8.0,
      this.borderRadius = 10.0})
      : assert(positionRatio >= 0 && positionRatio <= 1,
            'The position coefficient of the foam pointed angle must be 0-1 range'),
        assert(direction != null,
            'The direction of the foam pointed angle cannot be empty');

  /// Correct the size of the unsatisfactory compliance: [arrowHeight]
  getArrowHeightFit(Rect rect) {
    if (arrowHeight < 0) {
      return 0.0;
    }
    if (direction == ArrowDirection.left || direction == ArrowDirection.right) {
      if (arrowHeight > rect.width) {
        return rect.width;
      }
    } else {
      if (arrowHeight > rect.height) {
        return rect.height;
      }
    }
    return arrowHeight;
  }

  /// Correct the size of the unsatisfactory compliance: [borderRadius]
  getBorderRadiusFit(Rect rect) {
    if (borderRadius < 0) {
      return 0.0;
    }
    var maxRadius;
    var arrowHeightFit = getArrowHeightFit(rect);
    if (direction == ArrowDirection.left || direction == ArrowDirection.right) {
      maxRadius = 0.5 * min(rect.width - arrowHeightFit, rect.height);
    } else {
      maxRadius = 0.5 * min(rect.width, rect.height - arrowHeightFit);
    }
    if (borderRadius > maxRadius) {
      return maxRadius;
    }
    return borderRadius;
  }

  /// Correct the size of the unsatisfactory compliance: [arrowWidth]
  getArrowWidthFit(Rect rect) {
    if (arrowWidth < 0) {
      return 0.0;
    }
    var borderRadiusFit = getBorderRadiusFit(rect);
    var maxWidth;
    if (direction == ArrowDirection.left || direction == ArrowDirection.right) {
      maxWidth = rect.height - 2 * borderRadiusFit;
    } else {
      maxWidth = rect.width - 2 * borderRadiusFit;
    }
    if (arrowWidth > maxWidth) {
      return maxWidth;
    }
    return arrowWidth;
  }

  /// Correct the size of the unsatisfactory compliance: [positionRatio]
  getPositionRatioFit(Rect rect) {
    var borderRadiusFit = getBorderRadiusFit(rect);
    var arrowWidthFit = getArrowWidthFit(rect);
    var minPositionRatio;
    var maxPositionRatio;
    if (direction == ArrowDirection.left || direction == ArrowDirection.right) {
      minPositionRatio = (borderRadiusFit + 0.5 * arrowWidthFit) / rect.height;
      maxPositionRatio =
          (rect.height - borderRadiusFit - 0.5 * arrowWidthFit) / rect.height;
    } else {
      minPositionRatio = (borderRadiusFit + 0.5 * arrowWidthFit) / rect.width;
      maxPositionRatio =
          (rect.width - borderRadiusFit - 0.5 * arrowWidthFit) / rect.width;
    }
    if (positionRatio < minPositionRatio) {
      return minPositionRatio;
    }
    if (positionRatio > maxPositionRatio) {
      return maxPositionRatio;
    }
    return positionRatio;
  }

  // @override
  // EdgeInsetsGeometry? get dimensions => null;

  // @override
  // Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
  //   return null;
  // }

  // @override
  // ShapeBorder scale(double t) {
  //   return null;
  // }

  @override
  EdgeInsetsGeometry get dimensions => throw UnimplementedError();

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    throw UnimplementedError();
  }

  @override
  ShapeBorder scale(double t) {
    throw UnimplementedError();
  }

  /// Return to a Path object, that is, the cutting of the shape
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    var path = Path();
    _addBubblePath(path, rect);
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (style == BubbleStyle.stroke) {
      var paint = Paint()
        ..color = strokeColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      var path = Path();
      _addBubblePath(path, rect);
      canvas.drawPath(path, paint);
    }
  }

  /// Add bubble path
  _addBubblePath(Path path, Rect rect) {
    var w = rect.width;
    var h = rect.height;
    var borderRadiusFit = getBorderRadiusFit(rect);
    var positionRatioFit = getPositionRatioFit(rect);
    var arrowHeightFit = getArrowHeightFit(rect);
    var arrowWidthFit = getArrowWidthFit(rect);

    var xOffset = direction == ArrowDirection.left ? arrowHeightFit : 0.0;
    var yOffSet = direction == ArrowDirection.top ? arrowHeightFit : 0.0;
    var xOffsetEnd = direction == ArrowDirection.right ? arrowHeightFit : 0.0;
    var yOffSetEnd = direction == ArrowDirection.bottom ? arrowHeightFit : 0.0;

    // Speed at the bottom of the sharp corner X coordinates
    var xArrowCenter = positionRatioFit * w;
    // The bottom center of the sharp corner Y coordinates
    var yArrowCenter = positionRatioFit * h;
    path
      ..moveTo(xOffset, yOffSet + borderRadiusFit)
      // Add the upper left round corner
      ..arcTo(
          Rect.fromCircle(
              center:
                  Offset(xOffset + borderRadiusFit, yOffSet + borderRadiusFit),
              radius: borderRadiusFit),
          pi,
          0.5 * pi,
          false);
    // Add
    if (direction == ArrowDirection.top) {
      path
        ..lineTo(xArrowCenter - 0.5 * arrowWidthFit, yOffSet)
        ..lineTo(xArrowCenter, 0.0)
        ..lineTo(xArrowCenter + 0.5 * arrowWidthFit, yOffSet);
    }
    path.lineTo(w - xOffsetEnd - borderRadiusFit, yOffSet);
    // Add upper right corner
    path.arcTo(
        Rect.fromCircle(
            center: Offset(
                w - xOffsetEnd - borderRadiusFit, yOffSet + borderRadiusFit),
            radius: borderRadiusFit),
        -0.5 * pi,
        0.5 * pi,
        false);
    // Add to the right
    if (direction == ArrowDirection.right) {
      path
        ..lineTo(w - xOffsetEnd, yArrowCenter - 0.5 * arrowWidthFit)
        ..lineTo(w, yArrowCenter)
        ..lineTo(w - xOffsetEnd, yArrowCenter + 0.5 * arrowWidthFit);
    }
    path.lineTo(w - xOffsetEnd, h - yOffSetEnd - borderRadiusFit);
    // Add the lower right corner
    path.arcTo(
        Rect.fromCircle(
            center: Offset(w - xOffsetEnd - borderRadiusFit,
                h - yOffSetEnd - borderRadiusFit),
            radius: borderRadiusFit),
        0,
        0.5 * pi,
        false);
    // Add below
    if (direction == ArrowDirection.bottom) {
      path
        ..lineTo(xArrowCenter + 0.5 * arrowWidthFit, h - yOffSetEnd)
        ..lineTo(xArrowCenter, h)
        ..lineTo(xArrowCenter - 0.5 * arrowWidthFit, h - yOffSetEnd);
    }
    path.lineTo(xOffset + borderRadiusFit, h - yOffSetEnd);
    // Add the lower left corner
    path.arcTo(
        Rect.fromCircle(
            center: Offset(
                xOffset + borderRadiusFit, h - yOffSetEnd - borderRadiusFit),
            radius: borderRadiusFit),
        0.5 * pi,
        0.5 * pi,
        false);
    // Add left
    if (direction == ArrowDirection.left) {
      path
        ..lineTo(xOffset, yArrowCenter + 0.5 * arrowWidthFit)
        ..lineTo(0.0, yArrowCenter)
        ..lineTo(xOffset, yArrowCenter - 0.5 * arrowWidthFit);
    }
    // Direct flash ring means adding the left side
    path.close();
  }
}
