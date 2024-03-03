part of 'main.dart';

class _TransformEntryExample1 extends StatefulWidget {
  @override
  State<_TransformEntryExample1> createState() => _TransformEntryExample1State();
}

class _TransformEntryExample1State extends State<_TransformEntryExample1> with TickerProviderStateMixin {
  late final AnimationController elevationController;
  late final AnimationController rotationController;
  late Offset center;
  late double currentAngle;
  late double oldAngle;
  late double cumulativeAngle;
  VelocityTracker tracker = VelocityTracker.withKind(PointerDeviceKind.touch);
  bool down = false;
  late ExtensibleLinearSimulation simulation;

  @override
  void initState() {
    super.initState();
    elevationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    rotationController = AnimationController.unbounded(
      vsync: this,
    );
    rotationController.value = 2.22 * pi;

    oldAngle = currentAngle = cumulativeAngle = rotationController.value % (2 * pi);
  }

  get time => Duration(milliseconds: DateTime.now().millisecondsSinceEpoch);

  get rotation => rotationController.value;

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap down and move your finger around the center of the red circle\n'
               'you can fling it too',
      child: LayoutBuilder(
        builder: (context, constraints) {
          center = constraints.biggest.center(Offset.zero);
          return Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: Colors.grey.shade400,
              ),
              GestureDetector(
                onPanDown: (d) {
                  down = true;
                  tracker = VelocityTracker.withKind(PointerDeviceKind.touch);
                  rotationController.stop();
                  cumulativeAngle = oldAngle = rotation;
                  _updateAngle(d.localPosition, false);
                  simulation = ExtensibleLinearSimulation(
                    start: rotationController.value,
                    end: cumulativeAngle,
                    velocity: 2 * pi,
                  );
                  rotationController
                    .animateWith(simulation)
                    .whenCompleteOrCancel(_upElevation);
                },
                onPanUpdate: (d) {
                  if (rotationController.isAnimating) {
                    _updateAngle(d.localPosition, false);
                    simulation.extendTo(cumulativeAngle);
                  } else {
                    _updateAngle(d.localPosition);
                    tracker.addPosition(time, Offset(rotation, 0));
                  }
                },
                onPanEnd: (d) {
                  down = false;
                  tracker.addPosition(time, Offset(rotation, 0));
                  final v = tracker.getVelocity().pixelsPerSecond.dx;
                  rotationController
                    .animateWith(ClampingScrollSimulation(position: rotation, velocity: v, friction: 0.0001))
                    .whenCompleteOrCancel(elevationController.reverse);
                },
                child: CustomPaint(
                  painter: _RotatedLabelsPainter(rotationController, elevationController),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  _upElevation() {
    if (down) elevationController.forward();
  }

  @override
  dispose() {
    elevationController.dispose();
    rotationController.dispose();
    super.dispose();
  }

  _updateAngle(Offset position, [bool sync = true]) {
    currentAngle = (position - center).direction;
    final delta = (currentAngle - oldAngle + pi) % (2 * pi) - pi;
    cumulativeAngle += delta;
    oldAngle = currentAngle;
    if (sync) {
      rotationController.value = cumulativeAngle;
    }
  }
}

class _RotatedLabelsPainter extends CustomPainter {
  _RotatedLabelsPainter(this.rotationController, this.elevationController)
    : super(repaint: Listenable.merge([rotationController, elevationController]));

  final AnimationController rotationController;
  final AnimationController elevationController;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const records = [
      (Alignment(0.5, -0.25), 0.21, Colors.blue, Interval(0.5, 1.0),),
      (Alignment(-0.2, 0.35), 0.71, Colors.green, Interval(0.25, 0.75),),
      (Alignment(0, 0), 1.0, Colors.red, Interval(0.0, 0.5),),
    ];

    for (final (alignment, _, color, _) in records) {
      circlePaint.color = color.shade800.withOpacity(0.75);
      canvas
        ..drawCircle(alignment.withinRect(rect), rect.shortestSide * 0.25, circlePaint)
        ..drawCircle(alignment.withinRect(rect), rect.shortestSide * 0.075, circlePaint);
    }

    for (final (alignment, angleFactor, _, interval) in records) {
      final angle = (angleFactor * rotationController.value) % (2 * pi);
      final degrees = 180 * angle / pi;
      final builder = ui.ParagraphBuilder(ui.ParagraphStyle())
        ..pushStyle(ui.TextStyle(fontSize: 20, color: Colors.white))
        ..addText('${degrees.toStringAsFixed(1)}° = ')
        ..pushStyle(ui.TextStyle(color: Colors.orange))
        ..addText('${(angle / pi).toStringAsFixed(2)}𝜋');
      final paragraph = builder.build()
        ..layout(ui.ParagraphConstraints(width: rect.longestSide));
      final paragraphSize = Size(paragraph.longestLine, paragraph.height);
      const paragraphPadding = EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      );
      final boxSize = paragraphPadding.inflateSize(paragraphSize);

      final curve = (elevationController.status == AnimationStatus.reverse)? interval.flipped : interval;
      final t = curve.transform(elevationController.value);
      final matrix = composeMatrix(
        rotation: angle,
        anchor: Offset(-rect.shortestSide * 0.075 - lerpDouble(10, 2, t)!, boxSize.height / 2),
        translate: alignment.withinRect(rect),
      );
      canvas
        ..save()
        ..transform(matrix.storage);

      final leftColor = HSVColor.fromAHSV(1, degrees, 1, 0.8).toColor();
      final rightColor = HSVColor.fromAHSV(1, degrees, 1, 0.3).toColor();
      final background = BoxDecoration(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
        gradient: LinearGradient(
          colors: [
            Color.lerp(Colors.black, leftColor, t)!,
            Color.lerp(Colors.grey.shade600, rightColor, t)!,
          ],
        ),
        border: Border.all(width: 2, color: Colors.black38),
        boxShadow: [
          BoxShadow(
            blurRadius: 6 * t,
            offset: Offset.fromDirection(pi / 4 - angle, 12 * t),
            color: Colors.black.withOpacity(0.66),
          ),
        ],
      ).createBoxPainter();
      background.paint(canvas, Offset.zero, ImageConfiguration(size: boxSize));
      canvas
        ..drawParagraph(paragraph, paragraphPadding.topLeft)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_RotatedLabelsPainter oldDelegate) => false;
}

/// Simulates linear movement from [start] to [end] with a fixed, constant [velocity].
/// The [end] position can be extended with [extendBy] / [extendTo] methods making
/// the simulation shorter or longer depending on the new [end] value.
class ExtensibleLinearSimulation extends Simulation {

  ExtensibleLinearSimulation({
    required this.start,
    required double end,
    required double velocity,
  }) : assert(velocity > 0), _end = end, velocity = velocity * (end - start).sign;

  /// Start distance
  final double start;

  /// End distance, can be extended with [extendBy] / [extendTo] methods
  double get end => _end;
  double _end;

  /// Fixed velocity
  final double velocity;

  /// Extend [end] position by given [amount]
  void extendBy(double amount) => extendTo(_end + amount);

  /// Extend [end] position to [value]
  void extendTo(double value) {
    _end = velocity > 0? max(start, value) : min(start, value);
  }

  @override
  double x(double time) {
    final s = start + time * velocity;
    return velocity > 0? min(_end, s) : max(_end, s);
  }

  @override
  double dx(double time) => velocity;

  @override
  bool isDone(double time) => x(time) == _end;
}
