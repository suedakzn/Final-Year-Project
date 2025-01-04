import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'signin_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _shipController;
  late AnimationController _planeController;
  late AnimationController _dolphinController;
  late AnimationController _cloudController;
  late AnimationController _fishController;

  late Animation<double> _dolphinAnimation;
  late Animation<double> _cloudAnimation;
  late Animation<double> _fishAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    // Gemi kontrolcüsü
    _shipController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat(reverse: true);

    // Uçak kontrolcüsü
    _planeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat(reverse: true);

    // Yunus kontrolcüsü
    _dolphinController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _dolphinAnimation = Tween<double>(begin: 50, end: 250).animate(
      CurvedAnimation(parent: _dolphinController, curve: Curves.easeOut),
    );

    // Bulut kontrolcüsü
    _cloudController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat(reverse: true);

    _cloudAnimation = Tween<double>(begin: -50, end: 50).animate(
      CurvedAnimation(parent: _cloudController, curve: Curves.easeInOut),
    );

    // Balık kontrolcüsü
    _fishController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat(reverse: true);

    _fishAnimation = Tween<double>(begin: 0, end: 200).animate(
      CurvedAnimation(parent: _fishController, curve: Curves.linear),
    );

    // Konfeti kontrolcüsü
    _confettiController = ConfettiController(duration: Duration(seconds: 1));

    _startAnimations();
  }

  void _startAnimations() async {
    // Yunus hareketi
    await _dolphinController.forward();

    // Konfeti patlat
    _confettiController.play();

    // 2 saniye sonra Welcome ekranına geç
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _shipController.dispose();
    _planeController.dispose();
    _dolphinController.dispose();
    _cloudController.dispose();
    _fishController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gökyüzü
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlue.shade300, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Güneş
          Positioned(
            top: 30,
            left: 30,
            child: Image.asset('assets/sun.png', width: 100),
          ),
          // Bulutlar
          AnimatedBuilder(
            animation: _cloudController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: 50,
                    left: 30 + _cloudAnimation.value,
                    child: Image.asset('assets/cloud.png', width: 140),
                  ),
                  Positioned(
                    top: 80,
                    left: 200 - _cloudAnimation.value,
                    child: Image.asset('assets/cloud.png', width: 140),
                  ),
                  Positioned(
                    top: 150,
                    left: 100 + _cloudAnimation.value,
                    child: Image.asset('assets/cloud.png', width: 140),
                  ),
                  Positioned(
                    top: 180,
                    left: 250 - _cloudAnimation.value,
                    child: Image.asset('assets/cloud.png', width: 140),
                  ),
                  Positioned(
                    top: 220,
                    left: 50 + _cloudAnimation.value,
                    child: Image.asset('assets/cloud.png', width: 110),
                  ),
                ],
              );
            },
          ),
          // Deniz
          Positioned(
            bottom: 0,
            child: Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              color: Colors.blue.shade800,
            ),
          ),
          // Gemi (kırmızı çizgi hizasında hareket)
          AnimatedBuilder(
            animation: _shipController,
            builder: (context, child) {
              return Positioned(
                bottom: 180, // Kırmızı çizgi hizasında hareket
                left: _shipController.value * MediaQuery.of(context).size.width,
                child: Image.asset('assets/ship.png', width: 170),
              );
            },
          ),
          // Balıklar (deniz içinde yüzüyor)
          AnimatedBuilder(
            animation: _fishController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    bottom: 50,
                    left: 50 + _fishAnimation.value,
                    child: Image.asset('assets/fishes.png', width: 100),
                  ),
                ],
              );
            },
          ),
          // Uçak (yavaş hareket)
          AnimatedBuilder(
            animation: _planeController,
            builder: (context, child) {
              return Positioned(
                top: 100,
                left:
                    _planeController.value * MediaQuery.of(context).size.width,
                child: Image.asset('assets/airplane.png', width: 140),
              );
            },
          ),
          // Yunus (denizden zıplayarak çıkacak)
          AnimatedBuilder(
            animation: _dolphinController,
            builder: (context, child) {
              return Positioned(
                bottom: 100 + _dolphinAnimation.value,
                left: MediaQuery.of(context).size.width / 2 - 75,
                child: Opacity(
                  opacity: _dolphinAnimation.value > 100 ? 1.0 : 0.0,
                  child: Image.asset(
                    'assets/blue_dolphin.png',
                    width: 150,
                  ),
                ),
              );
            },
          ),
          // Konfeti
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.red, Colors.green, Colors.blue, Colors.yellow],
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _whaleController;
  late Animation<double> _whaleAnimation;

  @override
  void initState() {
    super.initState();

    // Balina kontrolcüsü
    _whaleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _whaleAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _whaleController, curve: Curves.easeInOut),
    );

    // 2 saniye sonra SignInPage'e geçiş
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    });
  }

  @override
  void dispose() {
    _whaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Text(
              "Welcome!",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _whaleController,
            builder: (context, child) {
              return Positioned(
                bottom: MediaQuery.of(context).size.height / 3 +
                    _whaleAnimation.value,
                left: MediaQuery.of(context).size.width / 2 - 75,
                child: Image.asset(
                  'assets/balina.png',
                  width: 150,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
