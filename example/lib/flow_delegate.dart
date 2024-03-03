part of 'main.dart';

class _TransformEntryExample0 extends StatefulWidget {
  @override
  State<_TransformEntryExample0> createState() => _TransformEntryExample0State();
}

class _TransformEntryExample0State extends State<_TransformEntryExample0> {
  late final ticker = Ticker(tick);
  final notifier = ValueNotifier(0);
  final colorNotifier = ValueNotifier(0.0);
  final position = ValueNotifier(const Offset(200, 200));
  Duration totalDuration = Duration.zero;
  Duration lastDuration = Duration.zero;
  final childOpacity = <double>[0.5, 1, 1];

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap down and move your finger',
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (d) {
          position.value = d.localPosition;
          ticker.start();
        },
        onPanUpdate: (d) {
          position.value = d.localPosition;
        },
        onPanEnd: (d) {
          totalDuration += lastDuration;
          ticker.stop();
        },
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  for (int i = 0; i < 3; i++)
                    Stack(
                      children: [
                        Slider(
                          value: childOpacity[i],
                          onChanged: (v) => setState(() => childOpacity[i] = v),
                        ),
                        Center(child: Text('child #$i opacity')),
                      ],
                    ),
                ],
              ),
            ),
            Flow(
              delegate: _TransformEntryExample0Delegate(notifier, position, childOpacity),
              children: [
                // child 0
                const SizedBox(
                  width: 150,
                  height: 150,
                  child: FlutterLogo(),
                ),
                // child 1
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    border: Border.symmetric(horizontal: BorderSide(width: 1, color: Colors.black87)),
                  ),
                  child: const FittedBox(child: Icon(Icons.place_outlined, color: Colors.orange)),
                ),
                // child 2
                ValueListenableBuilder<double>(
                  valueListenable: colorNotifier,
                  builder: (context, value, child) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: HSVColor.fromAHSV(1, value % 360, 1, 1).toColor(),
                      ),
                      child: const FittedBox(child: Text('child #2')),
                    );
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  tick(Duration duration) {
    lastDuration = duration;
    notifier.value = duration.inMilliseconds + totalDuration.inMilliseconds;

    colorNotifier.value = notifier.value / 50;
  }

  @override
  void dispose() {
    super.dispose();
    ticker.dispose();
  }
}

class _TransformEntryExample0Delegate extends FlowDelegate {
  _TransformEntryExample0Delegate(this.notifier, this.position, this.childOpacity) : super(repaint: notifier);

  final ValueNotifier<int> notifier;
  final ValueNotifier<Offset> position;
  final List<double> childOpacity;

  @override
  void paintChildren(FlowPaintingContext context) {
    final ms = notifier.value;
    // print(ms);

    context.paintChild(0,
      // defaults to:
      // scale: 1,
      transform: composeMatrix(
        translate: position.value,
        rotation: pi / 8 - pi * ms / 4200,
        anchor: Alignment.center.alongSize(context.getChildSize(0)!),
      ),
      opacity: childOpacity[0],
    );

    context.paintChild(1,
      // defaults to:
      // rotation: 0,
      transform: composeMatrix(
        translate: position.value,
        scale: 1 + pow(sin(pi * ms / 5000), 2) as double,
        anchor: Alignment.topCenter.alongSize(context.getChildSize(1)!),
        rotation: pi * 0.1 * sin(pi * ms / 500),
      ),
      opacity: childOpacity[1],
    );

    final childSize = context.getChildSize(2)!;
    context.paintChild(2,
      transform: composeMatrix(
        translate: position.value,
        scale: 1 + 0.5 * pow(sin(pi * ms / 1200), 2),
        rotation: pi * ms / 1000,
        // anchor: Alignment(1, 0.5).alongSize(childSize),
        anchor: Offset(childSize.width, childSize.height * (1 + sin(pi * ms / 900)) / 2),
      ),
      opacity: childOpacity[2],
    );
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) => true;
}
