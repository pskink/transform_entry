part of 'main.dart';

const tileSize = 64.0;
class _TransformEntryExample6 extends StatefulWidget {
  @override
  State<_TransformEntryExample6> createState() => _TransformEntryExample6State();
}

class _TransformEntryExample6State extends State<_TransformEntryExample6> {
  final r = Random();
  List<_Tile>? tiles;

  @override
  Widget build(BuildContext context) {
    return _ExampleFrame(
      tipText: 'tap any tile to start animation',
      child: LayoutBuilder(
        builder: (context, constraints) {
          tiles ??= _initialize(constraints).toList();
          return Stack(
            children: [
              const SizedBox.expand(),
              for (int i = 0; i < tiles!.length; i++)
                AnimatedTransformEntry(
                  duration: const Duration(milliseconds: 1000),
                  transformEntry: TransformEntry(
                    translate: tiles![i].translation,
                    rotation: tiles![i].rotation,
                    anchor: const Offset(tileSize / 2, tileSize / 2),
                  ),
                  curve: Curves.easeInOut,
                  child: SizedBox.fromSize(
                    size: const Size.square(tileSize),
                    child: CustomPaint(
                      foregroundPainter: _TransformEntryExample6Painter(
                        tiles![i].color, tiles![i].useCenter0, tiles![i].useCenter1,
                      ),
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            // timeDilation = 10;
                            tiles![i].rotation = tiles![i].rotation == 0? pi / 2 : 0;
                            final idx = r.nextInt(tiles!.length);
                            if (idx != i) {
                              _swap(tiles![i], tiles![idx]);
                            }
                          });
                        },
                        child: const SizedBox.expand()),
                    ),
                  ),
                ),
            ],
          );
        }
      ),
    );
  }

  Iterable<_Tile> _initialize(BoxConstraints constraints) sync* {
    for (int y = 0; y < (constraints.maxHeight / tileSize).ceil(); y++) {
      for (int x = 0; x < (constraints.maxWidth / tileSize).ceil(); x++) {
        final translation = Offset(tileSize * x + tileSize / 2, tileSize * y + tileSize / 2);
        final rotation = r.nextBool()? pi / 2 : 0.0;
        final color = r.nextBool()? const Color(0xff006600) : const Color(0xffaa0000);

        final b = r.nextDouble() < 0.125;
        yield _Tile(translation, rotation, color, b, b);

        // yield _Tile(translation, rotation, color, false, false);
      }
    }
  }

  void _swap(_Tile tile0, _Tile tile1) {
    final translation0 = tile0.translation;
    final rotation0 = tile0.rotation;

    tile0
      ..translation = tile1.translation
      ..rotation = tile1.rotation;
    tile1
      ..translation = translation0
      ..rotation = rotation0;
  }
}

class _Tile {
  _Tile(this.translation, this.rotation, this.color, this.useCenter0, this.useCenter1);

  Offset translation;
  double rotation;
  final Color color;
  final bool useCenter0;
  final bool useCenter1;
}

class _TransformEntryExample6Painter extends CustomPainter {
  _TransformEntryExample6Painter(this._color, this._useCenter0, this._useCenter1);

  final Color _color;
  final bool _useCenter0;
  final bool _useCenter1;
  final _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = size.shortestSide / 2;
    _paint.color = _color;

    // canvas
    //   ..drawArc(Rect.fromCircle(center: rect.center, radius: radius), 0, pi / 2, _useCenter0, _paint)
    //   ..drawArc(Rect.fromCircle(center: rect.center, radius: radius), pi, pi / 2, _useCenter0, _paint);

    canvas
      ..drawArc(Rect.fromCircle(center: rect.topLeft, radius: radius), 0, pi / 2, _useCenter0, _paint)
      ..drawArc(Rect.fromCircle(center: rect.bottomRight, radius: radius), pi, pi / 2, _useCenter1, _paint);
  }

  @override
  bool shouldRepaint(_TransformEntryExample6Painter oldDelegate) => false;
}
