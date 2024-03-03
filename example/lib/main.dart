import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:transform_entry/transform_entry.dart';
import 'package:intl/intl.dart' show DateFormat;

part 'flow_delegate.dart';
part 'rotating_labels.dart';
part 'clock.dart';
part 'rotating_square.dart';
part 'truchet_tiles.dart';

main() {
  final examples = [
    _TransformEntryExample0(),
    _TransformEntryExample1(),
    _TransformEntryExample2(),
    _TransformEntryExample3(),
    _TransformEntryExample4(),
    _TransformEntryExample5(),
    _TransformEntryExample6(),
  ];

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (ctx) => Scaffold(body: _StartPage()),
      for (int i = 0; i < examples.length; i++)
        'transformEntryExample$i': (ctx) => Scaffold(
          appBar: AppBar(
            titleTextStyle: Theme.of(ctx).textTheme.labelLarge,
            title: Text('_TransformEntryExample$i'),
          ),
          body: examples[i],
        ),
    },
  ));
}

class _StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('direct Matrix4 composing inside custom FlowDelegate'),
          subtitle: const Text('_TransformEntryExample0'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample0'),
        ),
        ListTile(
          title: const Text('direct Matrix4 composing inside custom CustomPainter'),
          subtitle: const Text('_TransformEntryExample1'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample1'),
        ),
        ListTile(
          title: const Text('clock'),
          subtitle: const Text('_TransformEntryExample2'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample2'),
        ),
        ListTile(
          title: const Text('using TransformEntryTween with Transform widget'),
          subtitle: const Text('_TransformEntryExample3'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample3'),
        ),
        ListTile(
          title: const Text('using TransformEntryTween with custom CustomPainter'),
          subtitle: const Text('_TransformEntryExample4'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample4'),
        ),
        ListTile(
          title: const Text('basic AnimatedTransformEntry example'),
          subtitle: const Text('_TransformEntryExample5'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample5'),
        ),
        ListTile(
          title: const Text('multiple AnimatedTransformEntry example showing Truchet tiles'),
          subtitle: const Text('_TransformEntryExample6'),
          onTap: () => Navigator.of(context).pushNamed('transformEntryExample6'),
        ),
      ],
    );
  }
}

class _ExampleFrame extends StatelessWidget {
  const _ExampleFrame({
    required this.child,
    required this.tipText,
  });

  final Widget child;
  final String tipText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: const Color(0xff33ff33),
            padding: const EdgeInsets.all(8),
            child: Text(tipText),
          ),
        ),
      ],
    );
  }
}
