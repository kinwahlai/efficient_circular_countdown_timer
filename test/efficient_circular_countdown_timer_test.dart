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
  });
}
