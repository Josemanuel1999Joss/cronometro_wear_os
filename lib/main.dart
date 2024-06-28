import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cronómetro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      home: const WatchScreen(),
    );
  }
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return TimerScreen(mode: mode);
          },
        );
      },
    );
  }
}

class TimerScreen extends StatefulWidget {
  final WearMode mode;

  const TimerScreen({required this.mode, super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late int _count;
  late String _strCount;
  late bool _isRunning;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _count = 0;
    _strCount = "00:00.00";
    _isRunning = false;
    _animationController = AnimationController(
      duration: const Duration(seconds: 10), // Adjust this to make particles move slower
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = widget.mode == WearMode.active ? Colors.green : Colors.grey[400]!;
    Color iconColor = widget.mode == WearMode.active ? Colors.green : Colors.grey[400]!;

    return Scaffold(
      backgroundColor: widget.mode == WearMode.active ? Colors.black : Colors.grey[800]!,
      body: SafeArea(
        child: Stack(
          children: [
            ParticleBackground(
              animation: _animationController,
              color: textColor,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.timer,
                  color: iconColor,
                  size: 24.0,
                ),
                const SizedBox(height: 10.0),
                Text(
                  "Cronómetro",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: Text(
                    _strCount,
                    style: TextStyle(
                      fontSize: 24.0,
                      color: textColor,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                if (widget.mode == WearMode.active) _buildWidgetButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (_isRunning) {
              _stopTimer();
            } else {
              _startTimer();
            }
          },
          child: Icon(
            _isRunning ? Icons.pause : Icons.play_arrow,
            color: Colors.green,
            size: 32.0,
          ),
        ),
        const SizedBox(width: 10.0),
        GestureDetector(
          onTap: _resetTimer,
          child: Icon(
            Icons.stop,
            color: Colors.green,
            size: 32.0,
          ),
        ),
      ],
    );
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _count += 1;
        int minutes = _count ~/ 6000;
        int seconds = (_count ~/ 100) % 60;
        int milliseconds = _count % 100;
        _strCount = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(2, '0')}";
      });
    });
  }

  void _stopTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _count = 0;
      _strCount = "00:00.00";
      _isRunning = false;
    });
  }
}

class ParticleBackground extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  ParticleBackground({required this.animation, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(animation.value, color),
          child: Container(),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Random random = Random();

  ParticlePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + progress * size.height) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
