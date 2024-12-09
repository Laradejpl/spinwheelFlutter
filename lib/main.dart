import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spinning Wheel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SpinningWheel(),
    );
  }
}

class FireParticle {
  Offset position;
  double size;
  double opacity;
  double angle;
  double speed;
  double life;
  double maxLife;

  FireParticle({
    required this.position,
    required this.size,
    required this.angle,
    required this.speed,
    required this.maxLife,
  }) : opacity = 1.0,
       life = maxLife;

  bool update(double deltaTime) {
    position = Offset(
      position.dx + cos(angle) * speed * deltaTime,
      position.dy + sin(angle) * speed * deltaTime,
    );
    
    life -= deltaTime;
    opacity = (life / maxLife).clamp(0.0, 1.0);
    size *= 1.02; // Légère croissance de la taille
    
    return life > 0;
  }
}

class FireParticleSystem extends StatefulWidget {
  final bool isActive;
  final Offset center;
  final double radius;

  const FireParticleSystem({
    super.key,
    required this.isActive,
    required this.center,
    required this.radius,
  });

  @override
  State<FireParticleSystem> createState() => _FireParticleSystemState();
}

class _FireParticleSystemState extends State<FireParticleSystem>
    with SingleTickerProviderStateMixin {
  final List<FireParticle> particles = [];
  final Random random = Random();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 16), _updateParticles);
  }

  void _updateParticles(Timer timer) {
    if (!mounted) return;

    setState(() {
      if (widget.isActive) {
        // Ajouter de nouvelles particules
        _addNewParticles();
      }

      // Mettre à jour et filtrer les particules existantes
      particles.removeWhere((particle) => !particle.update(0.016));
    });
  }

  void _addNewParticles() {
    for (int i = 0; i < 2; i++) {
      double angle = random.nextDouble() * 2 * pi;
      double distance = widget.radius;
      
      particles.add(FireParticle(
        position: Offset(
          widget.center.dx + cos(angle) * distance,
          widget.center.dy + sin(angle) * distance,
        ),
        size: random.nextDouble() * 10 + 10,
        angle: angle + pi * (random.nextDouble() * 0.5 - 0.25),
        speed: random.nextDouble() * 30 + 50,
        maxLife: random.nextDouble() * 0.5 + 0.5,
      ));
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: particles.map((particle) => Positioned(
        left: particle.position.dx - particle.size / 2,
        top: particle.position.dy - particle.size / 2,
        child: Container(
          width: particle.size,
          height: particle.size * 1.2,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 0.5),
              radius: 0.8,
              colors: [
                Colors.yellow.withOpacity(particle.opacity),
                Colors.orange.withOpacity(particle.opacity * 0.8),
                Colors.red.withOpacity(particle.opacity * 0.5),
                Colors.red.shade900.withOpacity(particle.opacity * 0.3),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(particle.opacity * 0.5),
                blurRadius: particle.size * 0.5,
                spreadRadius: particle.size * 0.2,
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class SpinningWheel extends StatefulWidget {
  const SpinningWheel({super.key});

  @override
  State<SpinningWheel> createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();
  final List<String> prizes = [
    '100\$',
    '50\$',
    '10\$',
    '200\$',
    '1\$',
    '0\$',
    '500\$',
    'Loose'
  ];
  double _targetAngle = 0;
  bool isSpinning = false;

  late ConfettiController _confettiController;
  final AudioPlayer _spinningPlayer = AudioPlayer();
  final AudioPlayer _victoryPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCirc,
    );

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    _controller.addStatusListener(_onAnimationStatus);
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    await _spinningPlayer.setSource(AssetSource('spinning_sound.wav'));
    await _spinningPlayer.setReleaseMode(ReleaseMode.stop);
    await _victoryPlayer.setSource(AssetSource('victory_sound.wav'));
    await _victoryPlayer.setReleaseMode(ReleaseMode.stop);
  }

  void _spinWheel() async {
    if (_controller.isAnimating) return;

    setState(() {
      isSpinning = true;
    });

    final randomAngle = _random.nextDouble() * 360.0;
    _targetAngle = randomAngle;
    final spinAngle = (360.0 * 5) + randomAngle;

    await _spinningPlayer.stop();
    await _victoryPlayer.stop();

    setState(() {
      _animation = Tween<double>(
        begin: 0,
        end: spinAngle,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCirc,
      ));
    });

    await _spinningPlayer.play(AssetSource('spinning_sound.wav'));
    
    _controller.forward(from: 0);
  }

  void _onAnimationStatus(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      setState(() {
        isSpinning = false;
      });

      int prizeIndex = _calculatePrizeIndex();
      if (prizes[prizeIndex] != 'Loose') {
        await _victoryPlayer.play(AssetSource('victory_sound.wav'));
        _confettiController.play();
      }

      _showPrizeDialog();
      _controller.reset();
    }
  }

  int _calculatePrizeIndex() {
    double normalizedAngle = (_targetAngle % 360);
    double adjustedAngle = (360 - normalizedAngle + 270) % 360;
    return ((adjustedAngle / 45).floor() % 8);
  }

  void _showPrizeDialog() {
    int prizeIndex = _calculatePrizeIndex();
    String prize = prizes[prizeIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            prize == 'Loose' ? 'Dommage! 😔' : 'Félicitations! 🎉',
            textAlign: TextAlign.center,
          ),
          content: Text(
            prize == 'Loose' ? 'Vous avez perdu!' : 'Vous avez gagné $prize!',
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Offset wheelCenter = Offset(size.width / 2, size.height / 2);

    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: Stack(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Système de particules de feu
                  FireParticleSystem(
                    isActive: isSpinning,
                    center: wheelCenter,
                    radius: 160, // Rayon de la roue
                  ),
                  
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _animation.value * pi / 180.0,
                                child: const SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: CustomPaint(
                                    painter: WheelPainter(),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 320,
                            height: 320,
                            child: CustomPaint(
                              painter: BeltPainter(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _spinWheel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'TOURNER',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Confettis de victoire
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 5,
                minBlastForce: 1,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.1,
                colors: const [
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.yellow,
                  Colors.purple,
                  Colors.orange,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    _confettiController.dispose();
    _spinningPlayer.dispose();
    _victoryPlayer.dispose();
    super.dispose();
  }
}

class WheelPainter extends CustomPainter {
  const WheelPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final List<Color> colors = [
      Colors.blue, // 100$
      Colors.red, // 50$
      Colors.green, // 10$
      Colors.orange, // 200$
      Colors.blue, // 1$
      Colors.red, // 0$
      Colors.green, // 500$
      Colors.orange, // Loose
    ];

    final List<String> amounts = [
      '100\$',
      '50\$',
      '10\$',
      '200\$',
      '1\$',
      '0\$',
      '500\$',
      'Loose'
    ];

    for (var i = 0; i < 8; i++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i];

      final startAngle = i * pi / 4;
      canvas.drawArc(rect, startAngle, pi / 4, true, paint);

      _drawText(
        canvas,
        center,
        radius * 0.7,
        amounts[i],
        startAngle + (pi / 8),
      );
    }
  }

  void _drawText(Canvas canvas, Offset center, double radius, String text, double angle) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final x = center.dx + radius * cos(angle) - textPainter.width / 2;
    final y = center.dy + radius * sin(angle) - textPainter.height / 2;

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BeltPainter extends CustomPainter {
  const BeltPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;

    canvas.drawCircle(center, radius, paint);

    final arrowPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx - 15, 10)
      ..lineTo(center.dx + 15, 10)
      ..lineTo(center.dx, 40)
      ..close();

    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}