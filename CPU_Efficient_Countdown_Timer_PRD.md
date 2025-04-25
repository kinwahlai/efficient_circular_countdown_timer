# Product Requirements Document: CPU-Efficient Circular Countdown Timer (Flutter)

**Version:** 0.0.1
**Date:** 2025-04-25
**Author:** Darren Lai

## 1. Introduction

### 1.1 Purpose
This document outlines the requirements for a new Flutter widget: `EfficientCircularCountdownTimer`. The primary goal is to provide a highly performant and customizable circular countdown timer component with significantly lower CPU usage compared to existing solutions, suitable for integration into various Flutter applications.

### 1.2 Scope
The scope includes the design, development, testing, and documentation of the `EfficientCircularCountdownTimer` widget. It will offer core countdown functionality, visual customization, and lifecycle callbacks while adhering to Clean Architecture principles and being developed using a Test-Driven Development (TDD) approach.

### 1.3 Goals
*   **High Performance:** Achieve minimal CPU usage during animation (<5% on typical mid-range devices under normal load).
*   **Customizability:** Offer extensive options for visual styling (colors, gradients, stroke, text).
*   **Functionality:** Provide standard timer controls (start, pause, resume, restart, reset) and callbacks.
*   **Testability:** Ensure high test coverage through TDD (Unit, Widget, Integration tests).
*   **Maintainability:** Follow Clean Architecture principles for clear separation of concerns.
*   **Ease of Use:** Provide a simple and intuitive API for developers.

### 1.4 Non-Goals
*   Support for platforms other than Flutter (iOS, Android, Web, Desktop where Flutter runs).
*   Advanced animation effects beyond simple circular progress (e.g., complex transitions).
*   Network-synchronized timing features.
*   Full accessibility compliance beyond basic considerations in v1.0.

### 1.5 Success Metrics
*   **SM1:** CPU usage measured via Flutter DevTools profiling consistently below 5% on a defined benchmark device (e.g., Pixel 5 or equivalent emulator profile) during active countdown with default settings.
*   **SM2:** Unit test coverage reported by `flutter test --coverage` is >= 90%.
*   **SM3:** Widget test coverage reported by `flutter test --coverage` is >= 80%.
*   **SM4:** No critical or high-severity bugs reported related to core functionality or performance within 2 weeks of internal release/testing.

### 1.6 Release Criteria (for v1.0)
*   **RC1:** All Functional Requirements (Section 2) implemented and verified by passing tests.
*   **RC2:** Performance target (NFR1.1, measured by SM1) met.
*   **RC3:** Test coverage requirements (NFR2.1, NFR2.2, measured by SM2, SM3) achieved.
*   **RC4:** API documentation (NFR4.2) and example usage (NFR4.3) are complete and accurate.
*   **RC5:** Basic accessibility considerations (NFR3.5) addressed.

## 2. Functional Requirements

### 2.1 Core Functionality
*   **FR1.1 Countdown:** The widget must count down from a specified `duration` (in seconds) to zero.
*   **FR1.2 Count Up:** Optionally, the widget must count up from zero to a specified `duration`. (Controlled by `isReverse` flag, default: false - count up).
*   **FR1.3 Initial Duration:** The timer can start from an `initialDuration` partway through the total `duration`.
*   **FR1.4 Auto Start:** The timer should automatically start upon initialization by default (`autoStart` flag, default: true).

### 2.2 Visual Representation
*   **FR2.1 Circular Progress:** Display progress visually as a circular ring or arc that fills/empties over the countdown duration.
    *   The direction of the fill/empty animation should be configurable (`isReverseAnimation` flag).
*   **FR2.2 Background Ring:** Display a background ring representing the total duration path.
*   **FR2.3 Text Display:** Optionally display the remaining (or elapsed) time as text centered within the circle (`isTimerTextShown` flag, default: true).
*   **FR2.4 Text Formatting:** Allow developers to specify the format of the displayed time string (e.g., `HH:MM:SS`, `MM:SS`, `SS`, `S`) via predefined constants or a custom formatting function.

### 2.3 Customization
*   **FR3.1 Dimensions:** Allow specifying `width` and `height` for the widget. It should maintain a 1:1 aspect ratio internally.
*   **FR3.2 Colors:** Allow customization of:
    *   `fillColor`: Color of the progress arc.
    *   `ringColor`: Color of the background ring.
    *   `backgroundColor`: Optional solid background color for the circle area.
*   **FR3.3 Gradients:** Allow customization of:
    *   `fillGradient`: Gradient for the progress arc (overrides `fillColor`).
    *   `ringGradient`: Gradient for the background ring (overrides `ringColor`).
    *   `backgroundGradient`: Optional gradient for the circle area (overrides `backgroundColor`).
*   **FR3.4 Stroke:** Allow customization of:
    *   `strokeWidth`: Thickness of the progress and background rings.
    *   `strokeCap`: Style of the start/end points of the progress arc (e.g., `StrokeCap.butt`, `StrokeCap.round`).
*   **FR3.5 Text Style:** Allow providing a `TextStyle` object to customize the appearance of the time text.
*   **FR3.6 Text Alignment:** Allow specifying `TextAlign` for the time text.

### 2.4 Control & Callbacks
*   **FR4.1 Controller:** Provide an optional `CountdownController` to programmatically control the timer:
    *   `start()`: Starts the timer (if not auto-started or after reset).
    *   `pause()`: Pauses the timer at the current progress.
    *   `resume()`: Resumes the timer from the paused state.
    *   `restart()`: Resets the timer to the beginning (0 or full duration) and starts it. Optionally accepts a new duration.
    *   `reset()`: Resets the timer to its initial state without starting it. Optionally accepts a new duration.
    *   `getTime()`: Returns the current formatted time string.
    *   Provide `ValueNotifier`s within the controller to listen for state changes (e.g., `isPaused`, `isStarted`).
*   **FR4.2 Callbacks:** Provide optional callback functions:
    *   `onStart()`: Called when the timer begins (or resumes from reset).
    *   `onComplete()`: Called when the timer reaches its end (0 for countdown, `duration` for count up).
    *   `onChange(String time)`: Called *only* when the displayed time string *changes* (typically once per second).

## 3. Non-Functional Requirements

### 3.1 Performance
*   **NFR1.1 CPU Efficiency:** The widget must minimize CPU usage. Repaints should be efficient, and state updates impacting the UI (especially text) should occur only when necessary (e.g., once per second), not on every animation frame. Target <5% CPU on a mid-range device during active countdown.
*   **NFR1.2 Memory Usage:** Minimize object creation, especially within painting and animation callbacks. Reuse `Paint` objects and cache `Shader` objects in the `CustomPainter`.
*   **NFR1.3 Rendering Isolation:** Utilize `RepaintBoundary` to isolate the timer's painting from the rest of the widget tree, preventing unnecessary repaints.

### 3.2 Testability (TDD Approach)
*   **NFR2.1 Unit Tests:** Business logic (time calculation, formatting, state transitions via controller) must be covered by unit tests with high coverage (>90%). Dependencies (like the animation controller state) should be mocked.
*   **NFR2.2 Widget Tests:** Core widget functionality, including rendering based on properties, basic animations, text updates via `ValueListenableBuilder`, and interactions with the `CustomPainter`, must be covered by widget tests (>80%). Test different configurations (colors, gradients, reverse modes, etc.).
*   **NFR2.3 Integration Tests:** (Optional but recommended) Test the timer's behavior within a simple app context, verifying controller actions and callbacks over time.
*   **NFR2.4 TDD Workflow:**
    1.  Write a failing test (Unit or Widget) for the smallest piece of required functionality.
    2.  Write the minimum amount of code (logic or UI) to make the test pass.
    3.  Refactor the code while ensuring all tests still pass.
    4.  Repeat for the next piece of functionality.

### 3.3 Architecture (Clean Architecture)
*   **NFR3.1 Separation of Concerns:** Maintain a clear separation:
    *   **Presentation (UI):** The `EfficientCircularCountdownTimer` widget itself, `ValueListenableBuilder` for text, `RepaintBoundary`, `CustomPaint`. Minimal logic.
    *   **State Management/Logic:** The `State` object managing the `AnimationController`, `ValueNotifier` for time string, handling controller interactions, calculating time, managing callbacks.
    *   **Painting:** The `CustomPainter` implementation, responsible *only* for drawing based on provided animation value and properties. Optimized for performance.
*   **NFR3.2 Dependency Rule:** UI layer depends on State Management; State Management depends on Painting primitives (implicitly via `CustomPaint`). Avoid reverse dependencies.
*   **NFR3.3 Data Flow:** Properties flow down from the widget constructor. State changes (time string, animation value) flow from the State Management layer to the UI/Painting layers. Controller actions flow into the State Management layer. Callbacks flow out from the State Management layer.

### 3.4 Usability & Documentation
*   **NFR4.1 API Design:** The widget's constructor and the `CountdownController` API should be intuitive and easy to use.
*   **NFR4.2 Documentation:** Provide clear inline documentation (doc comments) for the public API (widget, controller, properties, methods, callbacks).
*   **NFR4.3 Example Usage:** Include a comprehensive example demonstrating various features and customization options.

### 3.5 Basic Accessibility (A11y)
*   **NFR5.1 Contrast:** Ensure default color combinations for text and graphical elements meet WCAG AA minimum contrast ratios.
*   **NFR5.2 Semantics:** (Best Effort for v1.0) Explore wrapping the widget or its text component with basic `Semantics` information to announce the current time value to screen readers, if feasible without significant performance overhead or complexity. Full semantic tree optimization is out of scope for v1.0.

## 4. Design Considerations

*   **State Management:** Primarily use `StatefulWidget` with `AnimationController` and `ValueNotifier` for localized state. Avoid reliance on external state management packages for the core widget functionality to keep it self-contained, but ensure it's compatible with common patterns (Provider, Riverpod, etc.) when used in an app.
*   **Painting Optimization:** Focus heavily on optimizing the `CustomPainter`:
    *   Instantiate `Paint` objects outside the `paint` method.
    *   Cache `Shader` objects, recreating them only if the size or gradient properties change.
    *   Implement `shouldRepaint` correctly to avoid unnecessary paints.
*   **Text Update Strategy:** Use `ValueNotifier<String>` updated approximately once per second (triggered by animation listener logic or a separate `Timer`) and `ValueListenableBuilder` to ensure the `Text` widget rebuilds minimally.
*   **Error Handling/Edge Cases:** Use `assert` statements liberally during development within the widget's `State` and `Controller` to catch invalid configurations or states (e.g., negative duration, `initialDuration` > `duration`, invalid controller usage). Handle potential null values gracefully where applicable (e.g., gradients, optional callbacks).

## 5. Future Considerations (Out of Scope for v1.0)

*   More complex animation styles (e.g., easing curves beyond linear).
*   Full accessibility improvements (semantic labels, focus management).
*   Finer-grained control over animation timing (e.g., custom tickers).
*   Platform-specific optimizations if significant differences are observed.

## References
* [Flutter Documentation](https://flutter.dev/docs)
* [Circular Countdown Timer Examples](https://pub.dev/packages/circular_countdown_timer/example)