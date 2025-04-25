import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:efficient_circular_countdown_timer/efficient_circular_countdown_timer.dart';

void main() {
  group('EfficientCircularCountdownTimerLogic', () {
    test('counts up from initialDuration to duration', () {
      fakeAsync((async) {
        final logic = EfficientCircularCountdownTimerLogic(duration: 3);
        logic.start();
        expect(logic.currentSeconds, 0);
        async.elapse(const Duration(seconds: 1));
        expect(logic.currentSeconds, 1);
        async.elapse(const Duration(seconds: 2));
        expect(logic.currentSeconds, 3);
        expect(logic.isRunning, false); // Should stop at duration
        logic.dispose();
      });
    });

    test('counts down from initialDuration to 0', () {
      fakeAsync((async) {
        final logic = EfficientCircularCountdownTimerLogic(duration: 3, initialDuration: 3, isReverse: true);
        logic.start();
        expect(logic.currentSeconds, 3);
        async.elapse(const Duration(seconds: 1));
        expect(logic.currentSeconds, 2);
        async.elapse(const Duration(seconds: 2));
        expect(logic.currentSeconds, 0);
        expect(logic.isRunning, false); // Should stop at 0
        logic.dispose();
      });
    });

    test('pause and resume works', () {
      fakeAsync((async) {
        final logic = EfficientCircularCountdownTimerLogic(duration: 3);
        logic.start();
        async.elapse(const Duration(seconds: 1));
        logic.pause();
        final pausedAt = logic.currentSeconds;
        async.elapse(const Duration(seconds: 2));
        expect(logic.currentSeconds, pausedAt); // Should not change
        logic.resume();
        async.elapse(const Duration(seconds: 1));
        expect(logic.currentSeconds, pausedAt + 1);
        logic.dispose();
      });
    });

    test('reset sets timer to initialDuration', () {
      fakeAsync((async) {
        final logic = EfficientCircularCountdownTimerLogic(duration: 5, initialDuration: 2);
        logic.start();
        async.elapse(const Duration(seconds: 2));
        logic.reset();
        expect(logic.currentSeconds, 2);
        expect(logic.isRunning, false);
        logic.dispose();
      });
    });
  });

  group('Edge cases and error handling', () {
    test('throws exception for negative duration', () {
      expect(() => EfficientCircularCountdownTimerLogic(duration: -1), throwsA(isA<EfficientCircularCountdownTimerException>()));
    });
    test('throws exception for initialDuration < 0', () {
      expect(() => EfficientCircularCountdownTimerLogic(duration: 5, initialDuration: -1), throwsA(isA<EfficientCircularCountdownTimerException>()));
    });
    test('throws exception for initialDuration > duration', () {
      expect(() => EfficientCircularCountdownTimerLogic(duration: 3, initialDuration: 4), throwsA(isA<EfficientCircularCountdownTimerException>()));
    });
    testWidgets('rapid controller actions do not crash', (tester) async {
      final controller = CountdownController();
      await tester.pumpWidget(
        MaterialApp(
          home: EfficientCircularCountdownTimer(
            duration: 2,
            controller: controller,
            width: 100,
            height: 100,
          ),
        ),
      );
      controller.start();
      controller.pause();
      controller.resume();
      controller.reset();
      controller.restart();
      await tester.pumpAndSettle();
      expect(find.byType(EfficientCircularCountdownTimer), findsOneWidget);
    });
  });

  group('EfficientCircularCountdownTimer widget', () {
    testWidgets('displays initial time and completes', (tester) async {
      String? completed;
      final controller = CountdownController();
      await tester.pumpWidget(
        MaterialApp(
          home: EfficientCircularCountdownTimer(
            duration: 2,
            controller: controller,
            width: 100,
            height: 100,
            isTimerTextShown: true,
            onComplete: () => completed = 'done',
          ),
        ),
      );
      // Should show initial time
      expect(find.text('00:00'), findsOneWidget);
      // Start the timer
      controller.start();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('00:01'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('00:02'), findsOneWidget);
      // Timer should complete
      expect(completed, 'done');
    });

    testWidgets('onStart and onChange callbacks are triggered', (tester) async {
      bool started = false;
      final changes = <String>[];
      final controller = CountdownController();
      await tester.pumpWidget(
        MaterialApp(
          home: EfficientCircularCountdownTimer(
            duration: 2,
            controller: controller,
            width: 100,
            height: 100,
            isTimerTextShown: true,
            onStart: () => started = true,
            onChange: (value) => changes.add(value),
          ),
        ),
      );
      controller.start();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(started, isTrue);
      expect(changes.length, greaterThanOrEqualTo(2));
      expect(changes.first, '00:01');
    });

    testWidgets('controller pause, resume, reset, restart', (tester) async {
      final controller = CountdownController();
      await tester.pumpWidget(
        MaterialApp(
          home: EfficientCircularCountdownTimer(
            duration: 3,
            controller: controller,
            width: 100,
            height: 100,
            isTimerTextShown: true,
          ),
        ),
      );
      controller.start();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('00:01'), findsOneWidget);
      controller.pause();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      // Should remain paused
      expect(find.text('00:01'), findsOneWidget);
      controller.resume();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('00:02'), findsOneWidget);
      controller.reset();
      await tester.pumpAndSettle();
      expect(find.text('00:00'), findsOneWidget);
      controller.restart();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('00:01'), findsOneWidget);
    });

    testWidgets('isTimerTextShown hides text', (tester) async {
      final controller = CountdownController();
      await tester.pumpWidget(
        MaterialApp(
          home: EfficientCircularCountdownTimer(
            duration: 2,
            controller: controller,
            width: 100,
            height: 100,
            isTimerTextShown: false,
          ),
        ),
      );
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('custom timeFormatter is used', (tester) async {
      final controller = CountdownController();
      await tester.pumpWidget(
        MaterialApp(
          home: EfficientCircularCountdownTimer(
            duration: 2,
            controller: controller,
            width: 100,
            height: 100,
            isTimerTextShown: true,
            timeFormatter: (s) => 'S$s',
          ),
        ),
      );
      expect(find.text('S0'), findsOneWidget);
      controller.start();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('S1'), findsOneWidget);
    });
  });
}
