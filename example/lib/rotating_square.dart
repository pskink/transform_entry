part of 'main.dart';

class _TransformEntryExample3 extends StatefulWidget {
  @override
  State<_TransformEntryExample3> createState() => _TransformEntryExample3State();
}

class _TransformEntryExample3State extends State<_TransformEntryExample3> with TickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  final _intervals = List.generate(5, (index) {
    final begin = lerpDouble(0.2, 0.0, index / 4)!;
    return CurveTween(curve: Interval(begin, begin + 0.8));
  });
  Iterable<Animatable<TransformEntry>> _entries = [];
  Offset _beginOffset = Offset.zero, _endOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap anywhere to see orange square moving',
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (d) {
              // timeDilation = 10;
              _beginOffset = _endOffset;
              _endOffset = d.localPosition;
              _entries = _intervals.map((interval) => TransformEntryTween(
                begin: TransformEntry(
                  rotation: 0,
                  translate: _beginOffset,
                  anchor: const Offset(50, 50),
                ),
                end: TransformEntry(
                  rotation: pi,
                  translate: _endOffset,
                  anchor: const Offset(50, 50),
                ),
              ).chain(interval));
              _controller.forward(from: 0.0);
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double t = 0;
                final children = _entries.map((te) {
                  t = (t + 0.2).clamp(0, 1);
                  return Transform(
                    transform: te.animate(_controller).value.matrix,
                    child: SizedBox.fromSize(
                      size: const Size(100, 100),
                      child: Material(
                        color: HSVColor.fromAHSV(1.0, 40, t, 1.0).toColor(),
                        elevation: 4,
                      ),
                    ),
                  );
                }).toList();
                return Stack(
                  children: children,
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

// ============================================================================

class _TransformEntryExample4 extends StatefulWidget {
  @override
  State<_TransformEntryExample4> createState() => _TransformEntryExample4State();
}

class _TransformEntryExample4State extends State<_TransformEntryExample4> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  final _intervals = List.generate(5, (index) {
    final begin = lerpDouble(0.2, 0.0, index / 4)!;
    return CurveTween(curve: Interval(begin, begin + 0.8));
  });
  Iterable<Animatable<TransformEntry>> _entries = [];
  Offset _beginOffset = Offset.zero, _endOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap anywhere to see orange square moving',
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (d) {
              _beginOffset = _endOffset;
              _endOffset = d.localPosition;
              _entries = _intervals.map((interval) {
                final te0 = TransformEntry(
                  scale: 1,
                  rotation: 0,
                  translate: _beginOffset,
                  anchor: const Offset(50, 50),
                );
                final te1 = TransformEntry(
                  scale: 2,
                  rotation: pi / 2,
                  translate: (_beginOffset + _endOffset) / 2,
                  anchor: const Offset(50, 50),
                );
                final te2 = TransformEntry(
                  scale: 1,
                  rotation: pi,
                  translate: _endOffset,
                  anchor: const Offset(50, 50),
                );
                return TweenSequence<TransformEntry>([
                  TweenSequenceItem(tween: TransformEntryTween(begin: te0, end: te1), weight: 1),
                  TweenSequenceItem(tween: TransformEntryTween(begin: te1, end: te2), weight: 2),
                ]).chain(interval);
              });
              _controller.forward(from: 0.0);
              setState(() {});
            },
            child: CustomPaint(
              painter: TransformEntryExample4Painter(_controller, _entries),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class TransformEntryExample4Painter extends CustomPainter {
  TransformEntryExample4Painter(this._controller, this._entries) : super(repaint: _controller);

  final AnimationController _controller;
  final Iterable<Animatable<TransformEntry>> _entries;
  final _paint0 = Paint();
  final _paint1 = Paint()..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    // timeDilation = 10;
    final rect = Offset.zero & const Size(100, 100);
    double t = 0;
    for (final entry in _entries) {
      t = (t + 0.2).clamp(0, 1);
      final matrix = entry.animate(_controller).value.matrix;
      final color = HSVColor.fromAHSV(1.0, 40, t, 1.0).toColor();
      canvas
        ..save()
        ..transform(matrix.storage)
        ..drawRect(rect, _paint0..color = color)
        ..drawRect(rect, _paint1..color = Colors.black.withOpacity(t))
        ..restore();
    }
  }

  @override
  bool shouldRepaint(TransformEntryExample4Painter oldDelegate) => false;
}

// ============================================================================

class _TransformEntryExample5 extends StatefulWidget {
  @override
  State<_TransformEntryExample5> createState() => _TransformEntryExample5State();
}

class _TransformEntryExample5State extends State<_TransformEntryExample5> {
  final _intervals = List.generate(5, (index) {
    final begin = lerpDouble(0.2, 0.0, index / 4)!;
    return Interval(begin, begin + 0.8);
  });
  List<Widget> _children = [];
  double _rotation = 0;

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap anywhere to see orange square moving',
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (d) {
              // timeDilation = 10;
              _rotation += pi;
              double t = 0;
              _children = _intervals.map((interval) {
                t = (t + 0.2).clamp(0, 1);
                return AnimatedTransformEntry(
                  duration: const Duration(milliseconds: 750),
                  transformEntry: TransformEntry(
                    rotation: _rotation,
                    translate: d.localPosition,
                    anchor: const Offset(50, 50),
                  ),
                  curve: interval,
                  child: SizedBox.fromSize(
                    size: const Size(100, 100),
                    child: Material(
                      color: HSVColor.fromAHSV(1.0, 40, t, 1.0).toColor(),
                      elevation: 4,
                    ),
                  ),
                );
              }).toList();
              setState(() {});
            },
            child: Stack(
              children: _children,
            ),
          ),
        ],
      ),
    );
  }
}
