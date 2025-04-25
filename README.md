<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# EfficientCircularCountdownTimer

A highly efficient, customizable, and accessible circular countdown timer widget for Flutter. Designed for minimal CPU/memory usage and maximum flexibility.

## Features
- Circular countdown and count-up modes
- Highly customizable appearance (colors, gradients, stroke, text)
- Controller for start, pause, resume, reset, and more
- Callbacks for start, complete, and value changes
- Optimized for performance and accessibility

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

EfficientCircularCountdownTimer(
  duration: 10,
  controller: controller,
  width: 100,
  height: 100,
  fillColor: Colors.green,
  ringColor: Colors.grey[300]!,
  backgroundColor: Colors.white,
  strokeWidth: 8.0,
  textStyle: TextStyle(fontSize: 24, color: Colors.black),
  onComplete: () => print('Done!'),
)
```

See the [example](example/) for a full demo and advanced usage.

## License
See [LICENSE](LICENSE).
