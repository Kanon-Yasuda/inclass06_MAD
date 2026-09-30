// In-Class Activity 06 — Drawing with Flutter
// Student: Cassie Nguyen
// Date: September 26, 2026

import 'dart:math' show pi, Random;

import 'package:flutter/material.dart';

void main() => runApp(const SmileyApp());

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Drawing "state" — changing these + setState() triggers shouldRepaint
  double mood = 0.8; // 0.0 sad → 1.0 happy

  // Added for Level 3: selected face
  FaceType faceType = FaceType.classic;

  // Added for Level 4: random mood and face
  final Random random = Random();

  // Added for Level 4: tap to cycle faces
  void cycleFace() {
    setState(() {
      if (faceType == FaceType.classic) {
        faceType = FaceType.sleepy;
      } else if (faceType == FaceType.sleepy) {
        faceType = FaceType.surprised;
      } else {
        faceType = FaceType.classic;
      }
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Face changed to ${faceType.name}.'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  // Added for Level 4: long-press to randomize
  void randomizeFace() {
    setState(() {
      mood = random.nextDouble();

      final faceNumber = random.nextInt(3);

      if (faceNumber == 0) {
        faceType = FaceType.classic;
      } else if (faceNumber == 1) {
        faceType = FaceType.sleepy;
      } else {
        faceType = FaceType.surprised;
      }
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Randomized ${faceType.name} '
            'with mood ${mood.toStringAsFixed(2)}.',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomPainter Smiley Lab'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // The Expanded section lets the drawing use available space
            // without causing an overflow on smaller phone screens.
            Expanded(
              child: Center(
                child: GestureDetector(
                  // Level 4: tap to cycle faces
                  onTap: cycleFace,

                  // Level 4: long-press to randomize
                  onLongPress: randomizeFace,

                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: SmileyPainter(
                      mood: mood,
                      faceType: faceType,
                    ),
                  ),
                ),
              ),
            ),

            // Level 3: face selection
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      faceType = FaceType.classic;
                    });
                  },
                  child: const Text('Classic'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      faceType = FaceType.sleepy;
                    });
                  },
                  child: const Text('Sleepy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      faceType = FaceType.surprised;
                    });
                  },
                  child: const Text('Surprised'),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Face: ${faceType.name}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'Mood: ${mood.toStringAsFixed(2)}',
                  ),

                  // Level 2: mood slider
                  Slider(
                    value: mood,
                    onChanged: (double v) {
                      setState(() {
                        mood = v;
                      });
                    },
                  ),

                  const Text(
                    'Tap the face to cycle • Long-press to randomize',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Added for Level 3:
// A limited list of named face choices.
enum FaceType {
  classic,
  sleepy,
  surprised,
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.faceType,
  });

  final double mood;
  final FaceType faceType;

  @override
  void paint(Canvas canvas, Size size) {
    // Modules 2–3: base every position on size, center, or radius.
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.shortestSide * 0.4;

    // Level 2: face color changes based on mood.
    Color faceColor;

    if (mood < 0.35) {
      // Sad / cool
      faceColor = Colors.lightBlue.shade300;
    } else if (mood <= 0.7) {
      // Neutral / yellow
      faceColor = Colors.yellow.shade600;
    } else {
      // Happy / warm
      faceColor = Colors.orange.shade400;
    }

    // 1) Face
    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      radius,
      facePaint,
    );

    // 2) Face border
    final border = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(
      center,
      radius,
      border,
    );

    // 3) Draw the selected face
    if (faceType == FaceType.classic) {
      _drawClassic(canvas, center, radius);
    } else if (faceType == FaceType.sleepy) {
      _drawSleepy(canvas, center, radius);
    } else {
      _drawSurprised(canvas, center, radius);
    }
  }

  // Level 1 + Level 2:
  // Classic face with two eyes and a mood-controlled mouth.
  void _drawClassic(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    // Eyes
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    const eyeRadius = 12.0;

    final eyeY = center.dy - radius * 0.18;
    final eyeDx = radius * 0.35;

    canvas.drawCircle(
      Offset(center.dx - eyeDx, eyeY),
      eyeRadius,
      eyePaint,
    );

    canvas.drawCircle(
      Offset(center.dx + eyeDx, eyeY),
      eyeRadius,
      eyePaint,
    );

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final mouthRect = Rect.fromCenter(
      center: Offset(
        center.dx,
        center.dy + radius * 0.15,
      ),
      width: radius * 1.0,
      height: radius * (0.4 + mood * 0.5),
    );

    // Mood < 0.35 → frown
    if (mood < 0.35) {
      final frownRect = mouthRect.translate(
        0,
        radius * 0.25,
      );

      canvas.drawArc(
        frownRect,
        1.15 * pi,
        0.70 * pi,
        false,
        mouthPaint,
      );
    }

    // Mood 0.35–0.7 → soft smile
    else if (mood <= 0.7) {
      canvas.drawArc(
        mouthRect,
        0.15 * pi,
        0.55 * pi,
        false,
        mouthPaint,
      );
    }

    // Mood > 0.7 → big smile
    else {
      canvas.drawArc(
        mouthRect,
        0.15 * pi,
        0.70 * pi,
        false,
        mouthPaint,
      );
    }
  }

  // Level 3:
  // Sleepy face with closed curved eyes and a soft mouth.
  void _drawSleepy(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final eyeY = center.dy - radius * 0.18;
    final eyeDx = radius * 0.35;

    // Left sleepy eye
    final leftEyeRect = Rect.fromCenter(
      center: Offset(
        center.dx - eyeDx,
        eyeY,
      ),
      width: radius * 0.35,
      height: radius * 0.20,
    );

    canvas.drawArc(
      leftEyeRect,
      0,
      pi,
      false,
      eyePaint,
    );

    // Right sleepy eye
    final rightEyeRect = Rect.fromCenter(
      center: Offset(
        center.dx + eyeDx,
        eyeY,
      ),
      width: radius * 0.35,
      height: radius * 0.20,
    );

    canvas.drawArc(
      rightEyeRect,
      0,
      pi,
      false,
      eyePaint,
    );

    // Sleepy mouth
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final mouthRect = Rect.fromCenter(
      center: Offset(
        center.dx,
        center.dy + radius * 0.20,
      ),
      width: radius * 0.65,
      height: radius * 0.30,
    );

    canvas.drawArc(
      mouthRect,
      0.15 * pi,
      0.45 * pi,
      false,
      mouthPaint,
    );
  }

  // Level 3:
  // Surprised face with bigger eyes and an open mouth.
  void _drawSurprised(
    Canvas canvas,
    Offset center,
    double radius,
  ) {
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeRadius = radius * 0.10;

    final eyeY = center.dy - radius * 0.18;
    final eyeDx = radius * 0.35;

    // Bigger left eye
    canvas.drawCircle(
      Offset(center.dx - eyeDx, eyeY),
      eyeRadius,
      eyePaint,
    );

    // Bigger right eye
    canvas.drawCircle(
      Offset(center.dx + eyeDx, eyeY),
      eyeRadius,
      eyePaint,
    );

    // Open surprised mouth
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final mouthRect = Rect.fromCenter(
      center: Offset(
        center.dx,
        center.dy + radius * 0.20,
      ),
      width: radius * 0.45,
      height: radius * 0.60,
    );

    canvas.drawOval(
      mouthRect,
      mouthPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    // Repaint when either painter input changes.
    return oldDelegate.mood != mood ||
        oldDelegate.faceType != faceType;
  }
}