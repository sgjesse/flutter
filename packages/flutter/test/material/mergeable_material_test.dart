// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum RadiusType {
  Sharp,
  Shifting,
  Round
}

void matches(BorderRadius borderRadius, RadiusType top, RadiusType bottom) {
  final Radius cardRadius = kMaterialEdges[MaterialType.card].topLeft;

  if (top == RadiusType.Sharp) {
    expect(borderRadius.topLeft, equals(Radius.zero));
    expect(borderRadius.topRight, equals(Radius.zero));
  } else if (top == RadiusType.Shifting) {
    expect(borderRadius.topLeft.x, greaterThan(0.0));
    expect(borderRadius.topLeft.x, lessThan(cardRadius.x));
    expect(borderRadius.topLeft.y, greaterThan(0.0));
    expect(borderRadius.topLeft.y, lessThan(cardRadius.y));
    expect(borderRadius.topRight.x, greaterThan(0.0));
    expect(borderRadius.topRight.x, lessThan(cardRadius.x));
    expect(borderRadius.topRight.y, greaterThan(0.0));
    expect(borderRadius.topRight.y, lessThan(cardRadius.y));
  } else {
    expect(borderRadius.topLeft, equals(cardRadius));
    expect(borderRadius.topRight, equals(cardRadius));
  }

  if (bottom == RadiusType.Sharp) {
    expect(borderRadius.bottomLeft, equals(Radius.zero));
    expect(borderRadius.bottomRight, equals(Radius.zero));
  } else if (bottom == RadiusType.Shifting) {
    expect(borderRadius.bottomLeft.x, greaterThan(0.0));
    expect(borderRadius.bottomLeft.x, lessThan(cardRadius.x));
    expect(borderRadius.bottomLeft.y, greaterThan(0.0));
    expect(borderRadius.bottomLeft.y, lessThan(cardRadius.y));
    expect(borderRadius.bottomRight.x, greaterThan(0.0));
    expect(borderRadius.bottomRight.x, lessThan(cardRadius.x));
    expect(borderRadius.bottomRight.y, greaterThan(0.0));
    expect(borderRadius.bottomRight.y, lessThan(cardRadius.y));
  } else {
    expect(borderRadius.bottomLeft, equals(cardRadius));
    expect(borderRadius.bottomRight, equals(cardRadius));
  }
}

BorderRadius getBorderRadius(WidgetTester tester, int index) {
  List<Element> containers = tester.elementList(find.byType(Container))
                                   .toList();

  Container container = containers[index + 2].widget;
  BoxDecoration boxDecoration = container.decoration;

  return boxDecoration.borderRadius;
}

class TestCanvas implements Canvas {
  final List<Invocation> invocations = <Invocation>[];

  @override
  void noSuchMethod(Invocation invocation) {
    invocations.add(invocation);
  }
}

class TestPaintingContext implements PaintingContext {
  TestPaintingContext(this.canvas);

  @override
  final Canvas canvas;

  @override
  void noSuchMethod(Invocation invocation) {

  }
}

void main() {
  testWidgets('MergeableMaterial empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial()
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(0));
  });

  testWidgets('MergeableMaterial update slice', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(100.0));

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 200.0
                )
              )
            ]
          )
        )
      )
    );

    box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(200.0));
  });

  testWidgets('MergeableMaterial swap slices', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(200.0));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(200.0));

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, equals(200.0));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Round);
  });

  testWidgets('MergeableMaterial paints shadows', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    TestCanvas canvas = new TestCanvas();

    box.paint(new TestPaintingContext(canvas), Offset.zero);

    final Invocation drawCommand = canvas.invocations.firstWhere((Invocation invocation) {
      return invocation.memberName == #drawRRect;
    });
    final BoxShadow boxShadow = kElevationToShadow[2][0];
    final RRect rrect = kMaterialEdges[MaterialType.card].toRRect(
      new Rect.fromLTRB(0.0, 0.0, 800.0, 100.0)
    );

    expect(drawCommand.positionalArguments[0], equals(rrect));
    expect(drawCommand.positionalArguments[1].color, equals(boxShadow.color));
    expect(drawCommand.positionalArguments[1].maskFilter, isNotNull);
  });

  testWidgets('MergeableMaterial merge gap', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('x')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 1), RadiusType.Round, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, lessThan(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Shifting);
    matches(getBorderRadius(tester, 1), RadiusType.Shifting, RadiusType.Round);

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, equals(200));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Round);
  });

  testWidgets('MergeableMaterial separate slices', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(200));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('x')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, lessThan(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Shifting);
    matches(getBorderRadius(tester, 1), RadiusType.Shifting, RadiusType.Round);

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, equals(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 1), RadiusType.Round, RadiusType.Round);
  });

  testWidgets('MergeableMaterial separate merge seaparate', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(200));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('x')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, lessThan(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Shifting);
    matches(getBorderRadius(tester, 1), RadiusType.Shifting, RadiusType.Round);

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, equals(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 1), RadiusType.Round, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, lessThan(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Shifting);
    matches(getBorderRadius(tester, 1), RadiusType.Shifting, RadiusType.Round);

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, equals(200));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('x')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, lessThan(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Shifting);
    matches(getBorderRadius(tester, 1), RadiusType.Shifting, RadiusType.Round);

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, equals(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 1), RadiusType.Round, RadiusType.Round);
  });

  testWidgets('MergeableMaterial insert slice', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(200));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump();
    expect(box.size.height, equals(300));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Sharp);
    matches(getBorderRadius(tester, 2), RadiusType.Sharp, RadiusType.Round);
  });

  testWidgets('MergeableMaterial remove slice', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(300));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Sharp);
    matches(getBorderRadius(tester, 2), RadiusType.Sharp, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump();
    expect(box.size.height, equals(200));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Round);
  });

  testWidgets('MergeableMaterial insert chunk', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(200));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('x')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('y')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, lessThan(332));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Shifting);
    matches(getBorderRadius(tester, 1), RadiusType.Shifting, RadiusType.Shifting);
    matches(getBorderRadius(tester, 2), RadiusType.Shifting, RadiusType.Round);

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, equals(332));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 1), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 2), RadiusType.Round, RadiusType.Round);
  });

  testWidgets('MergeableMaterial remove chunk', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('x')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('y')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(332));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 1), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 2), RadiusType.Round, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, lessThan(332));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Shifting);
    matches(getBorderRadius(tester, 1), RadiusType.Shifting, RadiusType.Round);

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, equals(200));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Sharp);
    matches(getBorderRadius(tester, 1), RadiusType.Sharp, RadiusType.Round);
  });

  testWidgets('MergeableMaterial replace gap with chunk', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('x')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 1), RadiusType.Round, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('y')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('z')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, lessThan(332));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Shifting);
    matches(getBorderRadius(tester, 1), RadiusType.Shifting, RadiusType.Shifting);
    matches(getBorderRadius(tester, 2), RadiusType.Shifting, RadiusType.Round);

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, equals(332));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 1), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 2), RadiusType.Round, RadiusType.Round);
  });

  testWidgets('MergeableMaterial replace chunk with gap', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('x')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('B'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('y')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    RenderBox box = tester.renderObject(find.byType(MergeableMaterial));
    expect(box.size.height, equals(332));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 1), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 2), RadiusType.Round, RadiusType.Round);

    await tester.pumpWidget(
      new Scaffold(
        body: new ScrollableViewport(
          child: new MergeableMaterial(
            children: <MergeableMaterialItem>[
              new MaterialSlice(
                key: new ValueKey<String>('A'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              ),
              new MaterialGap(
                key: new ValueKey<String>('z')
              ),
              new MaterialSlice(
                key: new ValueKey<String>('C'),
                child: new SizedBox(
                  width: 100.0,
                  height: 100.0
                )
              )
            ]
          )
        )
      )
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, lessThan(332));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Shifting);
    matches(getBorderRadius(tester, 1), RadiusType.Shifting, RadiusType.Round);

    await tester.pump(const Duration(milliseconds: 100));
    expect(box.size.height, equals(216));

    matches(getBorderRadius(tester, 0), RadiusType.Round, RadiusType.Round);
    matches(getBorderRadius(tester, 1), RadiusType.Round, RadiusType.Round);
  });
}
