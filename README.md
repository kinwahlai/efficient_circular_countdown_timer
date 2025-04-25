# EfficientCircularCountdownTimer

A highly efficient, customizable, and accessible circular countdown timer widget for Flutter. Designed for minimal CPU/memory usage and maximum flexibility.

## Features
- Circular countdown and count-up modes
- Highly customizable appearance (colors, gradients, stroke, text)
- Controller for start, pause, resume, reset, and more
- Callbacks for start, complete, and value changes
- Optimized for performance and accessibility (low CPU usage)

## Getting Started
Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  efficient_circular_countdown_timer:
    git:
      url: <your-repo-url>
```

Import and use in your widget tree:

```dart
import 'package:efficient_circular_countdown_timer/efficient_circular_countdown_timer.dart';

final controller = CountdownController();

EfficientCircularCountdownTimer(
  duration: 10,
  controller: controller,
  width: 100,
  height: 100,
  fillColor: Colors.green,
  ringColor: Colors.grey[300],
  backgroundColor: Colors.white,
  strokeWidth: 8.0,
  textStyle: TextStyle(fontSize: 24, color: Colors.black),
  isReverse: true,
  isReverseAnimation: false,
  autoStart: true,
  onStart: () => print('Started!'),
  onComplete: () => print('Done!'),
  onChange: (value) => print('Time: $value'),
)
```

## API Reference

### Widget Properties
| Property              | Type                        | Description |
|-----------------------|-----------------------------|-------------|
| duration              | int                         | Total duration in seconds |
| initialDuration       | int                         | Initial value in seconds (default: 0) |
| isReverse             | bool                        | Count down if true, up if false |
| autoStart             | bool                        | Start automatically (default: true) |
| width, height         | double                      | Size of the timer |
| fillColor             | Color?                      | Progress arc color |
| ringColor             | Color?                      | Background ring color |
| backgroundColor       | Color?                      | Circle background color |
| fillGradient          | Gradient?                   | Progress arc gradient (overrides fillColor) |
| ringGradient          | Gradient?                   | Ring gradient (overrides ringColor) |
| backgroundGradient    | Gradient?                   | Background gradient (overrides backgroundColor) |
| strokeWidth           | double                      | Thickness of rings |
| strokeCap             | StrokeCap                   | Arc end style |
| isReverseAnimation    | bool                        | Reverse arc animation direction |
| isTimerTextShown      | bool                        | Show timer text (default: true) |
| textStyle             | TextStyle?                  | Timer text style |
| textAlign             | TextAlign?                  | Timer text alignment |
| timeFormatter         | String Function(int)?       | Custom time formatter |
| controller            | CountdownController?        | Programmatic control |
| onStart               | VoidCallback?               | Called when timer starts |
| onComplete            | VoidCallback?               | Called when timer completes |
| onChange              | ValueChanged<String>?       | Called when timer value changes |

### Controller Usage
```dart
final controller = CountdownController();
controller.start();
controller.pause();
controller.resume();
controller.reset();
controller.restart();
```

## Example
See the [example](example/) directory for a full demo and advanced usage, including custom formatting and controller integration.

## Performance
- Designed to update only once per second for minimal CPU usage (~2% on typical devices).
- Uses RepaintBoundary and paint/shader caching for efficient rendering.
- **Efficient update strategy:** Instead of using a continuous animation, the timer only triggers a UI update when the timer value changes (typically once per second). This eliminates unnecessary repaints and keeps CPU usage extremely low, even for long-running timers.

## License
See [LICENSE](LICENSE).
