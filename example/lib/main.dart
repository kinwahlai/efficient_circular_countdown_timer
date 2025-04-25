import 'package:flutter/material.dart';
import 'package:efficient_circular_countdown_timer/efficient_circular_countdown_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circular Countdown Timer Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Circular Countdown Timer Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CountdownController _controller = CountdownController();
  String _status = 'Idle';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            EfficientCircularCountdownTimer(
              duration: 100,
              initialDuration: 100,
              controller: _controller,
              width: 120,
              height: 120,
              ringColor: Colors.grey[300],
              fillColor: Colors.blue,
              backgroundColor: Colors.white,
              strokeWidth: 10.0,
              strokeCap: StrokeCap.round,
              textStyle: const TextStyle(fontSize: 32, color: Colors.black),
              isReverse: true,
              isReverseAnimation: true,
              autoStart: false,
              onStart: () => setState(() => _status = 'Started'),
              onComplete: () => setState(() => _status = 'Completed'),
              onChange: (val) => setState(() => _status = 'Time: $val'),
            ),
            const SizedBox(height: 24),
            Text(_status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.start(),
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.pause(),
                  child: const Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.resume(),
                  child: const Text('Resume'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.reset(),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
