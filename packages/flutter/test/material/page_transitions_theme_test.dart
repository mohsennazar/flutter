// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

void main() {
  testWidgetsWithLeakTracking('Default PageTransitionsTheme platform', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('home')));
    final PageTransitionsTheme theme = Theme.of(tester.element(find.text('home'))).pageTransitionsTheme;
    expect(theme.builders, isNotNull);
    for (final TargetPlatform platform in TargetPlatform.values) {
      switch (platform) {
        case TargetPlatform.android:
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          expect(
            theme.builders[platform],
            isNotNull,
            reason: 'theme builder for $platform is null',
          );
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          expect(
            theme.builders[platform],
            isNull,
            reason: 'theme builder for $platform is not null',
          );
      }
    }
  });

  testWidgetsWithLeakTracking('Default PageTransitionsTheme builds a CupertinoPageTransition', (WidgetTester tester) async {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      '/': (BuildContext context) => Material(
        child: TextButton(
          child: const Text('push'),
          onPressed: () { Navigator.of(context).pushNamed('/b'); },
        ),
      ),
      '/b': (BuildContext context) => const Text('page b'),
    };

    await tester.pumpWidget(
      MaterialApp(
        routes: routes,
      ),
    );

    expect(Theme.of(tester.element(find.text('push'))).platform, debugDefaultTargetPlatformOverride);
    expect(find.byType(CupertinoPageTransition), findsOneWidget);

    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    expect(find.text('page b'), findsOneWidget);
    expect(find.byType(CupertinoPageTransition), findsOneWidget);
  }, variant: const TargetPlatformVariant(<TargetPlatform>{ TargetPlatform.iOS,  TargetPlatform.macOS }));

  testWidgetsWithLeakTracking('Default PageTransitionsTheme builds a _ZoomPageTransition for android', (WidgetTester tester) async {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      '/': (BuildContext context) => Material(
        child: TextButton(
          child: const Text('push'),
          onPressed: () { Navigator.of(context).pushNamed('/b'); },
        ),
      ),
      '/b': (BuildContext context) => const Text('page b'),
    };

    await tester.pumpWidget(
      MaterialApp(
        routes: routes,
      ),
    );

    Finder findZoomPageTransition() {
      return find.descendant(
        of: find.byType(MaterialApp),
        matching: find.byWidgetPredicate((Widget w) => '${w.runtimeType}' == '_ZoomPageTransition'),
      );
    }

    expect(Theme.of(tester.element(find.text('push'))).platform, debugDefaultTargetPlatformOverride);
    expect(findZoomPageTransition(), findsOneWidget);

    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    expect(find.text('page b'), findsOneWidget);
    expect(findZoomPageTransition(), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgetsWithLeakTracking('PageTransitionsTheme override builds a _OpenUpwardsPageTransition', (WidgetTester tester) async {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      '/': (BuildContext context) => Material(
        child: TextButton(
          child: const Text('push'),
          onPressed: () { Navigator.of(context).pushNamed('/b'); },
        ),
      ),
      '/b': (BuildContext context) => const Text('page b'),
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(), // creates a _OpenUpwardsPageTransition
            },
          ),
        ),
        routes: routes,
      ),
    );

    Finder findOpenUpwardsPageTransition() {
      return find.descendant(
        of: find.byType(MaterialApp),
        matching: find.byWidgetPredicate((Widget w) => '${w.runtimeType}' == '_OpenUpwardsPageTransition'),
      );
    }

    expect(Theme.of(tester.element(find.text('push'))).platform, debugDefaultTargetPlatformOverride);
    expect(findOpenUpwardsPageTransition(), findsOneWidget);

    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    expect(find.text('page b'), findsOneWidget);
    expect(findOpenUpwardsPageTransition(), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgetsWithLeakTracking('PageTransitionsTheme override builds a _FadeUpwardsTransition', (WidgetTester tester) async {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      '/': (BuildContext context) => Material(
        child: TextButton(
          child: const Text('push'),
          onPressed: () { Navigator.of(context).pushNamed('/b'); },
        ),
      ),
      '/b': (BuildContext context) => const Text('page b'),
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(), // creates a _FadeUpwardsTransition
            },
          ),
        ),
        routes: routes,
      ),
    );

    Finder findFadeUpwardsPageTransition() {
      return find.descendant(
        of: find.byType(MaterialApp),
        matching: find.byWidgetPredicate((Widget w) => '${w.runtimeType}' == '_FadeUpwardsPageTransition'),
      );
    }

    expect(Theme.of(tester.element(find.text('push'))).platform, debugDefaultTargetPlatformOverride);
    expect(findFadeUpwardsPageTransition(), findsOneWidget);

    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    expect(find.text('page b'), findsOneWidget);
    expect(findFadeUpwardsPageTransition(), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  Widget boilerplate({
    required bool themeAllowSnapshotting,
    bool secondRouteAllowSnapshotting = true,
  }) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(
              allowSnapshotting: themeAllowSnapshotting,
            ),
          },
        ),
      ),
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/') {
          return MaterialPageRoute<Widget>(
            builder: (_) => const Material(child: Text('Page 1')),
          );
        }
        return MaterialPageRoute<Widget>(
          builder: (_) => const Material(child: Text('Page 2')),
          allowSnapshotting: secondRouteAllowSnapshotting,
        );
      },
    );
  }

  bool isTransitioningWithSnapshotting(WidgetTester tester, Finder of) {
    final Iterable<Layer> layers = tester.layerListOf(
      find.ancestor(of: of, matching: find.byType(SnapshotWidget)).first,
    );
    final bool hasOneOpacityLayer = layers.whereType<OpacityLayer>().length == 1;
    final bool hasOneTransformLayer = layers.whereType<TransformLayer>().length == 1;
    // When snapshotting is on, the OpacityLayer and TransformLayer will not be
    // applied directly.
    return !(hasOneOpacityLayer && hasOneTransformLayer);
  }

  testWidgetsWithLeakTracking('ZoomPageTransitionsBuilder default route snapshotting behavior', (WidgetTester tester) async {
    await tester.pumpWidget(
      boilerplate(themeAllowSnapshotting: true),
    );

    final Finder page1 = find.text('Page 1');
    final Finder page2 = find.text('Page 2');

    // Transitioning from page 1 to page 2.
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/2');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Exiting route should be snapshotted.
    expect(isTransitioningWithSnapshotting(tester, page1), isTrue);

    // Entering route should be snapshotted.
    expect(isTransitioningWithSnapshotting(tester, page2), isTrue);

    await tester.pumpAndSettle();

    // Transitioning back from page 2 to page 1.
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Exiting route should be snapshotted.
    expect(isTransitioningWithSnapshotting(tester, page2), isTrue);

    // Entering route should be snapshotted.
    expect(isTransitioningWithSnapshotting(tester, page1), isTrue);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android), skip: kIsWeb); // [intended] rasterization is not used on the web.

  testWidgetsWithLeakTracking('ZoomPageTransitionsBuilder.allowSnapshotting can disable route snapshotting', (WidgetTester tester) async {
    await tester.pumpWidget(
      boilerplate(themeAllowSnapshotting: false),
    );

    final Finder page1 = find.text('Page 1');
    final Finder page2 = find.text('Page 2');

    // Transitioning from page 1 to page 2.
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/2');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Exiting route should not be snapshotted.
    expect(isTransitioningWithSnapshotting(tester, page1), isFalse);

    // Entering route should not be snapshotted.
    expect(isTransitioningWithSnapshotting(tester, page2), isFalse);

    await tester.pumpAndSettle();

    // Transitioning back from page 2 to page 1.
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Exiting route should not be snapshotted.
    expect(isTransitioningWithSnapshotting(tester, page2), isFalse);

    // Entering route should not be snapshotted.
    expect(isTransitioningWithSnapshotting(tester, page1), isFalse);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android), skip: kIsWeb); // [intended] rasterization is not used on the web.

  testWidgetsWithLeakTracking('Setting PageRoute.allowSnapshotting to false overrides ZoomPageTransitionsBuilder.allowSnapshotting = true', (WidgetTester tester) async {
    await tester.pumpWidget(
      boilerplate(
        themeAllowSnapshotting: true,
        secondRouteAllowSnapshotting: false,
      ),
    );

    final Finder page1 = find.text('Page 1');
    final Finder page2 = find.text('Page 2');

    // Transitioning from page 1 to page 2.
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/2');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // First route should be snapshotted.
    expect(isTransitioningWithSnapshotting(tester, page1), isTrue);

    // Second route should not be snapshotted.
    expect(isTransitioningWithSnapshotting(tester, page2), isFalse);

    await tester.pumpAndSettle();
  }, variant: TargetPlatformVariant.only(TargetPlatform.android), skip: kIsWeb); // [intended] rasterization is not used on the web.

  testWidgets('_ZoomPageTransition only causes child widget built once', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/58345

    int builtCount = 0;

    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      '/': (BuildContext context) => Material(
        child: TextButton(
          child: const Text('push'),
          onPressed: () { Navigator.of(context).pushNamed('/b'); },
        ),
      ),
      '/b': (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          builtCount++; // Increase [builtCount] each time the widget build
          return TextButton(
            child: const Text('pop'),
            onPressed: () { Navigator.pop(context); },
          );
        },
      ),
    };

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(), // creates a _ZoomPageTransition
            },
          ),
        ),
        routes: routes,
      ),
    );

    // No matter push or pop was called, the child widget should built only once.
    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();
    expect(builtCount, 1);

    await tester.tap(find.text('pop'));
    await tester.pumpAndSettle();
    expect(builtCount, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
