part of 'main.dart';

class _TransformEntryExample2 extends StatefulWidget {
  @override
  State<_TransformEntryExample2> createState() => _TransformEntryExample2State();
}

class _TransformEntryExample2State extends State<_TransformEntryExample2> with TickerProviderStateMixin {
  late final ctrl = AnimationController.unbounded(vsync: this);
  late final rotationCtrl = AnimationController.unbounded(vsync: this);
  final timeNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _startTime();
  }

  bool loop = true;
  _startTime() async {
    debugPrint('_startTime');
    final now = DateTime.now();
    double delta = now.second >= 30? 15 : 45;
    rotationCtrl.value = now.hour * 60.0 * 60 + now.minute * 60 + now.second + delta;
    while (loop) {
      final now = DateTime.now();
      ctrl.value = now.hour * 60.0 * 60 + now.minute * 60 + now.second;
      timeNotifier.value = ctrl.value.round();
      final ms = 1000 - now.millisecond;
      debugPrint('wait ${ms}ms');
      await Future.delayed(Duration(milliseconds: ms));
      if (!loop) break;

      final target = (ctrl.value + 1).roundToDouble();
      if (target % 60 == 0) delta += 30;
      if (target % 60 == 30) delta += 30;

      final curve = (ctrl.value % 20) < 10? Curves.elasticOut : Curves.bounceOut;
      rotationCtrl.animateTo(
        target + delta,
        duration: const Duration(milliseconds: 400),
        curve: target % 30 == 0? Curves.easeOut : curve,
      );

      await ctrl.animateTo(
        target,
        duration: const Duration(milliseconds: 400),
        curve: curve,
      );
    }
    debugPrint('_startTime bye bye');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide * 0.5;
        return Container(
          color: Colors.blueGrey,
          padding: const EdgeInsets.all(16),
          child: Flow(
            delegate: ClockDelegate(ctrl, rotationCtrl),
            children: [
              CustomPaint(
                painter: ClockPainter(),
                child: const SizedBox.expand(),
              ),
              _hand(const Size(4, 120), 30, Colors.teal, true),
              _hand(const Size(3, 120), 40, Colors.orange, true),
              _hand(const Size(1.5, 120), 50, Colors.black54, false),
              _digits(side),
            ],
          ),
        );
      }
    );
  }

  static final offset1 = Tween(begin: const Offset(0, 1), end: const Offset(0, 0));
  static final offset2 = Tween(begin: const Offset(0, -1), end: const Offset(0, 0));

  Widget _digits(double side) {
    final style = TextStyle(
      color: Colors.white24,
      fontSize: side * 0.45,
      fontWeight: FontWeight.w200,
    );
    return AnimatedBuilder(
      animation: timeNotifier,
      builder: (context, child) {
        final dt = DateTime.fromMillisecondsSinceEpoch(timeNotifier.value * 1000);
        final timeStr = DateFormat.ms().format(dt);

        Widget digitsMapper(idx) {
          if (idx == -1) return Text(':', style: style);
          final text = Text(timeStr[idx],
            style: style,
            key: ValueKey(timeStr[idx]),
          );
          if (idx == 4) return text;

          final begin0 = 0.1 * (3 - idx);
          final begin1 = 0.1 * idx;
          return ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Interval(begin0, begin0 + 0.7, curve: Curves.easeInOutBack),
              switchOutCurve: Interval(begin1, begin1 + 0.7, curve: Curves.easeInOut),
              transitionBuilder: (child, animation) => SlideTransition(
                position: (animation.value == 1? offset1 : offset2).animate(animation),
                child: child,
              ),
              child: text,
            ),
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [0, 1, -1, 3, 4].map(digitsMapper).toList(),
        );
      }
    );
  }

  @override
  void dispose() {
    loop = false;
    ctrl
      ..stop()
      ..dispose();
    rotationCtrl
      ..stop()
      ..dispose();
    super.dispose();
  }

  Widget _hand(Size size, double innerHeight, Color color, bool sharpEnd) {
    return Container(
      width: size.width,
      height: size.height,
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: size.width,
        height: innerHeight,
        child: Transform.translate(
          offset: Offset(0, size.height / 2 - innerHeight + size.width / 2),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: sharpEnd?
                    Radius.elliptical(size.width / 2, innerHeight) :
                    Radius.circular(size.width / 4),
                  bottom: Radius.circular(size.width / 2),
                )
              ),
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class ClockDelegate extends FlowDelegate {
  ClockDelegate(this.ctrl, this.rotationCtrl) : super(repaint: Listenable.merge([ctrl, rotationCtrl]));

  final AnimationController ctrl;
  final AnimationController rotationCtrl;

  @override
  void paintChildren(FlowPaintingContext context) {
    final center = context.size.center(Offset.zero);

    context.paintChild(0); // background CustomPaint

    final transform = composeMatrix(
      anchor: context.getChildSize(4)!.bottomCenter(Offset.zero),
      rotation: rotationCtrl.value * 2 * pi / 60,
      translate: center,
    );
    context.paintChild(4, transform: transform); // digits

    for (final hand in [1, 2, 3]) {
      final handSize = context.getChildSize(hand)!;
      context.paintChild(hand,
        transform: composeMatrix(
          rotation: switch (hand) {
            1 => ctrl.value * 2 * pi / (60 * 60 * 12), // hours hand
            2 => ctrl.value * 2 * pi / (60 * 60),      // minutes hand
            3 => (ctrl.value % 60) * 2 * pi / 60,      // seconds hand
            _ => 0, // no such case
          },
          translate: center,
          anchor: handSize.center(Offset.zero),
          scale: context.size.shortestSide / handSize.height,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => false;
}

class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    debugPrint('ClockPainter.paint');
    final center = size.center(Offset.zero);
    final ringWidth = size.shortestSide * 0.05;
    BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(width: ringWidth, color: Colors.white30),
      color: Colors.black26,
    ).createBoxPainter().paint(canvas, Offset.zero, ImageConfiguration(size: size));

    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final matrix = composeMatrix(
      anchor: center,
      translate: center, rotation: pi / 30,
    );
    final p1 = center.translate(0, -(size.shortestSide * 0.5 - ringWidth * 1.5));
    final p2 = p1.translate(0, ringWidth);
    final p3 = p1.translate(0, ringWidth * 2);
    for (int i = 0; i < 60; i++) {
      canvas.drawLine(p1, i % 5 == 0? p3 : p2, paint);
      canvas.transform(matrix.storage);
    }
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) => false;
}
