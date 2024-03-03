
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'transform_entry.dart';

class AnimatedTransformEntry extends ImplicitlyAnimatedWidget {
  const AnimatedTransformEntry({
    super.key,
    required this.transformEntry,
    this.child,
    super.curve,
    required super.duration,
    super.onEnd,
  });

  final TransformEntry transformEntry;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  AnimatedWidgetBaseState<AnimatedTransformEntry> createState() => _AnimatedTransformEntryState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TransformEntry>('transformEntry', transformEntry));
  }
}

class _AnimatedTransformEntryState extends AnimatedWidgetBaseState<AnimatedTransformEntry> {
  TransformEntryTween? _transformEntry;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: _transformEntry!.evaluate(animation).matrix,
      child: widget.child,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _transformEntry = visitor(_transformEntry, widget.transformEntry, (dynamic value) => TransformEntryTween(begin: value as TransformEntry)) as TransformEntryTween?;
  }
}
