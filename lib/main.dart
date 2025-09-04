import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async'; // Required for Future.delayed and Timer

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colorful Tic Tac Toe',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const ModeSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Animated App Icon Widget
class AnimatedAppIcon extends StatefulWidget {
  const AnimatedAppIcon({super.key});

  @override
  State<AnimatedAppIcon> createState() => _AnimatedAppIconState();
}

class _AnimatedAppIconState extends State<AnimatedAppIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Repeat the animation back and forth
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: const Icon(
        Icons.casino, // A suitable icon for a game
        size: 100,
        color: Colors.deepPurple,
      ),
    );
  }
}

// Mode selection
class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Game Mode')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AnimatedAppIcon(), // Animated icon
            const SizedBox(height: 20),
            const Text(
              'Made by Manoj S Arya',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<TicTacToeHome>(builder: (_) => const TicTacToeHome(isSinglePlayer: false)),
                );
              },
              child: const Text('Two Players', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<TicTacToeHome>(builder: (_) => const TicTacToeHome(isSinglePlayer: true)),
                );
              },
              child: const Text('Play with Computer', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}

// Data model for a single falling paper particle
class _PaperParticle {
  Offset position;
  double rotation;
  double size;
  Color color;
  double opacity;
  double velocityY;
  double rotationSpeed;

  _PaperParticle({
    required this.position,
    required this.rotation,
    required this.size,
    required this.color,
    required this.opacity,
    required this.velocityY,
    required this.rotationSpeed,
  });
}

// CustomPainter for drawing falling paper particles
class _PaperFallingPainter extends CustomPainter {
  final List<_PaperParticle> particles;

  _PaperFallingPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final _PaperParticle particle in particles) {
      final Paint paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: particle.size, height: particle.size * 0.7),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PaperFallingPainter oldDelegate) {
    return true; // Always repaint as particles are constantly moving
  }
}

// Widget for the falling papers animation
class _PaperFallingAnimationWidget extends StatefulWidget {
  final bool showAnimation;

  const _PaperFallingAnimationWidget({super.key, required this.showAnimation});

  @override
  State<_PaperFallingAnimationWidget> createState() => _PaperFallingAnimationWidgetState();
}

class _PaperFallingAnimationWidgetState extends State<_PaperFallingAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_PaperParticle> _particles = <_PaperParticle>[];
  final Random _random = Random();
  Timer? _particleGeneratorTimer;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Total animation duration
    )..addListener(() {
        _updateParticles();
      });

    if (widget.showAnimation) {
      startAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant _PaperFallingAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnimation != oldWidget.showAnimation) {
      if (widget.showAnimation) {
        startAnimation();
      } else {
        stopAnimation();
      }
    }
  }

  void startAnimation() {
    if (_isAnimating) return;
    _isAnimating = true;
    _particles.clear();
    _controller.reset();
    _controller.forward();

    // Generate particles periodically
    _particleGeneratorTimer = Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
      if (_particles.length < 50 && _isAnimating) { // Limit number of particles to avoid too many objects
        _generateParticle();
      }
    });

    // Stop animation after its duration
    Future<void>.delayed(_controller.duration ?? const Duration(seconds: 3), () {
      if (mounted) {
        stopAnimation();
      }
    });
  }

  void stopAnimation() {
    if (!_isAnimating) return;
    _isAnimating = false;
    _controller.stop();
    _particleGeneratorTimer?.cancel();
    _particles.clear();
    if (mounted) {
      setState(() {}); // Rebuild to clear particles
    }
  }

  void _generateParticle() {
    const List<Color> colors = <Color>[
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.yellowAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
    ];

    _particles.add(
      _PaperParticle(
        position: Offset(_random.nextDouble() * MediaQuery.of(context).size.width, -50.0), // Start above screen
        rotation: _random.nextDouble() * 2 * pi,
        size: 10.0 + _random.nextDouble() * 20.0,
        color: colors[_random.nextInt(colors.length)],
        opacity: 1.0,
        velocityY: 1.0 + _random.nextDouble() * 3.0,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.1, // Random small rotation
      ),
    );
  }

  void _updateParticles() {
    if (!mounted) return;
    setState(() {
      final List<_PaperParticle> activeParticles = <_PaperParticle>[];
      for (final _PaperParticle particle in _particles) {
        // Move particle
        particle.position = Offset(particle.position.dx, particle.position.dy + particle.velocityY);
        // Rotate particle
        particle.rotation += particle.rotationSpeed;
        // Fade out particle as it gets lower
        if (particle.position.dy > MediaQuery.of(context).size.height * 0.7) {
          particle.opacity -= 0.05; // Fade faster at the bottom
        } else if (particle.position.dy > MediaQuery.of(context).size.height * 0.5) {
          particle.opacity -= 0.02; // Start fading
        }

        // Keep particle if visible and on screen
        if (particle.opacity > 0 && particle.position.dy < MediaQuery.of(context).size.height + particle.size) {
          activeParticles.add(particle);
        }
      }
      _particles = activeParticles;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleGeneratorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true, // Don't block taps on the game board
      child: AnimatedOpacity(
        opacity: _isAnimating ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: CustomPaint(
          painter: _PaperFallingPainter(_particles),
          child: Container(), // Empty container to provide size for CustomPaint
        ),
      ),
    );
  }
}

// Main Game
class TicTacToeHome extends StatefulWidget {
  final bool isSinglePlayer;
  const TicTacToeHome({super.key, required this.isSinglePlayer});

  @override
  _TicTacToeHomeState createState() => _TicTacToeHomeState();
}

class _TicTacToeHomeState extends State<TicTacToeHome> with SingleTickerProviderStateMixin {
  List<String> board = List<String>.filled(9, '');
  bool xTurn = true;
  String winner = '';
  List<List<int>> winPatterns = const [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
  List<int> winningTiles = <int>[];

  final GlobalKey<_PaperFallingAnimationWidgetState> _paperAnimationKey = GlobalKey<_PaperFallingAnimationWidgetState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void playMove(int index) {
    if (board[index] == '' && winner == '') {
      setState(() {
        board[index] = xTurn ? 'X' : 'O';
        checkWinner();
        xTurn = !xTurn;

        if (widget.isSinglePlayer && !xTurn && winner == '') {
          aiMove();
        }
      });
    }
  }

  void aiMove() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    List<int> empty = <int>[];
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') empty.add(i);
    }
    if (empty.isNotEmpty) {
      int move = empty[Random().nextInt(empty.length)];
      setState(() {
        board[move] = 'O';
        checkWinner();
        xTurn = true;
      });
    }
  }

  void checkWinner() {
    for (List<int> pattern in winPatterns) {
      if (board[pattern[0]] != '' &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        winner = board[pattern[0]];
        winningTiles = pattern;
        _paperAnimationKey.currentState?.startAnimation(); // Trigger falling papers animation
        return;
      }
    }
    if (!board.contains('') && winner == '') {
      winner = 'Draw';
    }
  }

  void resetBoard() {
    setState(() {
      board = List<String>.filled(9, '');
      winner = '';
      xTurn = true;
      winningTiles = <int>[];
      _paperAnimationKey.currentState?.stopAnimation(); // Stop animation on reset
    });
  }

  Widget buildTile(int index) {
    Color bgColor;
    if (winningTiles.contains(index)) {
      bgColor = Colors.yellowAccent.shade100;
    } else if (board[index] == 'X') {
      bgColor = Colors.blue.shade100;
    } else if (board[index] == 'O') {
      bgColor = Colors.red.shade100;
    } else {
      bgColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => playMove(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              board[index],
              key: ValueKey<String>(board[index]),
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: board[index] == 'X' ? Colors.blue : Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSinglePlayer ? 'Tic Tac Toe (Single Player)' : 'Tic Tac Toe (Two Players)'),
        backgroundColor: Colors.purple,
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.refresh), onPressed: resetBoard),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Turn: ${xTurn ? 'X' : 'O'}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              const SizedBox(height: 20),
              Center( // Added Center to ensure the game board is centered
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: <Color>[Colors.purple.shade50, Colors.purple.shade100]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(color: Colors.black26, offset: Offset(0, 4), blurRadius: 8),
                    ],
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: 9,
                    itemBuilder: (_, int index) => buildTile(index),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                winner == '' ? '' : (winner == 'Draw' ? 'It\'s a Draw!' : '$winner Wins! 🎉'),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          // Falling papers animation overlay
          Positioned.fill(
            child: _PaperFallingAnimationWidget(
              key: _paperAnimationKey,
              showAnimation: winner != '' && winner != 'Draw',
            ),
          ),
        ],
      ),
    );
  }
}